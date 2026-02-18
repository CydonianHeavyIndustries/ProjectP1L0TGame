(function initSignupPage() {
  const signupForm = document.getElementById("signup-form");
  const verifyForm = document.getElementById("verify-form");
  const tabSignup = document.getElementById("tab-signup");
  const tabVerify = document.getElementById("tab-verify");
  const verifyIdentityInput = document.getElementById("verify-identity");
  const verifyCodeInput = document.getElementById("verify-code");
  const resendButton = document.getElementById("resend-btn");
  const statusEl = document.getElementById("status");
  const usersKey = "chii_signup_users_v1";
  const verificationTtlMs = 15 * 60 * 1000;
  const resendCooldownMs = 30 * 1000;

  if (
    !signupForm ||
    !verifyForm ||
    !tabSignup ||
    !tabVerify ||
    !verifyIdentityInput ||
    !verifyCodeInput ||
    !resendButton ||
    !statusEl
  ) {
    return;
  }

  const setStatus = (message, kind) => {
    statusEl.textContent = message;
    statusEl.classList.remove("ok", "error");
    if (kind) statusEl.classList.add(kind);
  };

  const switchTab = (tab) => {
    const showSignup = tab === "signup";
    signupForm.classList.toggle("hidden", !showSignup);
    verifyForm.classList.toggle("hidden", showSignup);
    tabSignup.classList.toggle("tab-active", showSignup);
    tabVerify.classList.toggle("tab-active", !showSignup);
  };

  const normalizeIdentity = (value) => String(value || "").trim().toLowerCase();

  const hashText = (text) => {
    let hash = 5381;
    for (let i = 0; i < text.length; i += 1) {
      hash = (hash * 33) ^ text.charCodeAt(i);
    }
    return `h${(hash >>> 0).toString(16)}`;
  };

  const generateVerificationCode = () => `${Math.floor(100000 + Math.random() * 900000)}`;

  const readTimestamp = (value) => {
    const parsed = Date.parse(value || "");
    return Number.isNaN(parsed) ? 0 : parsed;
  };

  const getUserByIdentity = (users, identity) =>
    users.find(
      (user) =>
        normalizeIdentity(user.username) === normalizeIdentity(identity) ||
        normalizeIdentity(user.email) === normalizeIdentity(identity)
    );

  const readUsers = () => {
    try {
      const raw = localStorage.getItem(usersKey);
      const parsed = raw ? JSON.parse(raw) : [];
      return Array.isArray(parsed) ? parsed : [];
    } catch (_error) {
      return [];
    }
  };

  const writeUsers = (users) => {
    localStorage.setItem(usersKey, JSON.stringify(users));
  };

  tabSignup.addEventListener("click", () => switchTab("signup"));
  tabVerify.addEventListener("click", () => switchTab("verify"));

  signupForm.addEventListener("submit", (event) => {
    event.preventDefault();

    const username = String(signupForm.username.value || "").trim();
    const email = String(signupForm.email.value || "").trim().toLowerCase();
    const password = String(signupForm.password.value || "");

    if (username.length < 3) {
      setStatus("Username must have at least 3 characters.", "error");
      return;
    }
    if (!email.includes("@")) {
      setStatus("Enter a valid email address.", "error");
      return;
    }
    if (password.length < 8) {
      setStatus("Password must have at least 8 characters.", "error");
      return;
    }

    const users = readUsers();
    const exists = users.some(
      (user) => user.username.toLowerCase() === username.toLowerCase() || user.email.toLowerCase() === email
    );

    if (exists) {
      setStatus("Username or email already exists.", "error");
      return;
    }

    const code = generateVerificationCode();
    const now = new Date().toISOString();

    users.push({
      id: `usr_${Date.now()}`,
      username,
      email,
      // Placeholder only. Replace with server-side auth before production.
      passwordHash: hashText(password),
      emailVerified: false,
      verificationCodeHash: hashText(code),
      verificationSentAt: now,
      createdAt: now,
    });

    writeUsers(users);
    signupForm.reset();
    verifyIdentityInput.value = email;
    verifyCodeInput.value = "";
    switchTab("verify");
    setStatus(`Signup complete. Validation code sent from noreply@cydonianheavyindustries.inc to ${email}. (DEV CODE: ${code})`, "ok");
  });

  verifyForm.addEventListener("submit", (event) => {
    event.preventDefault();

    const identity = normalizeIdentity(verifyIdentityInput.value);
    const code = String(verifyCodeInput.value || "").trim();
    if (!identity) {
      setStatus("Enter username or email.", "error");
      return;
    }
    if (!/^\d{6}$/.test(code)) {
      setStatus("Validation code must be 6 digits.", "error");
      return;
    }

    const users = readUsers();
    const matched = getUserByIdentity(users, identity);
    if (!matched) {
      setStatus("User not found.", "error");
      return;
    }
    if (matched.emailVerified) {
      setStatus("Email already verified.", "ok");
      return;
    }

    const sentAtMs = readTimestamp(matched.verificationSentAt);
    if (!sentAtMs || Date.now() - sentAtMs > verificationTtlMs) {
      setStatus("Validation code expired. Request a new one.", "error");
      return;
    }

    if (matched.verificationCodeHash !== hashText(code)) {
      setStatus("Invalid validation code.", "error");
      return;
    }

    const nextUsers = users.map((user) =>
      user.id === matched.id
        ? {
            ...user,
            emailVerified: true,
            verificationCodeHash: undefined,
            verificationSentAt: undefined,
            verifiedAt: new Date().toISOString(),
          }
        : user
    );
    writeUsers(nextUsers);
    verifyCodeInput.value = "";
    setStatus("Email validated. Pilot profile is now active.", "ok");
  });

  resendButton.addEventListener("click", () => {
    const identity = normalizeIdentity(verifyIdentityInput.value);
    if (!identity) {
      setStatus("Enter username or email before requesting a new code.", "error");
      return;
    }

    const users = readUsers();
    const matched = getUserByIdentity(users, identity);
    if (!matched) {
      setStatus("User not found.", "error");
      return;
    }
    if (matched.emailVerified) {
      setStatus("Email already verified.", "ok");
      return;
    }

    const sentAtMs = readTimestamp(matched.verificationSentAt);
    if (sentAtMs && Date.now() - sentAtMs < resendCooldownMs) {
      const remaining = Math.ceil((resendCooldownMs - (Date.now() - sentAtMs)) / 1000);
      setStatus(`Please wait ${remaining}s before requesting another code.`, "error");
      return;
    }

    const code = generateVerificationCode();
    const now = new Date().toISOString();
    const nextUsers = users.map((user) =>
      user.id === matched.id
        ? {
            ...user,
            verificationCodeHash: hashText(code),
            verificationSentAt: now,
          }
        : user
    );
    writeUsers(nextUsers);
    verifyCodeInput.value = "";
    setStatus(`Validation code re-sent from noreply@cydonianheavyindustries.inc to ${matched.email}. (DEV CODE: ${code})`, "ok");
  });

  switchTab("signup");
})();
