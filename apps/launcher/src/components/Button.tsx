import type { ButtonHTMLAttributes, ReactNode } from 'react';

interface ButtonProps extends ButtonHTMLAttributes<HTMLButtonElement> {
  variant?: 'primary' | 'danger' | 'ghost';
  children: ReactNode;
  className?: string;
}

const variantClass = (variant: ButtonProps['variant']) => {
  if (variant === 'primary') return 'button button-primary';
  if (variant === 'danger') return 'button button-danger';
  if (variant === 'ghost') return 'button button-ghost';
  return 'button';
};

const Button = ({ variant, children, className, ...rest }: ButtonProps) => (
  <button className={`${variantClass(variant)} ${className ?? ''}`.trim()} {...rest}>
    {children}
  </button>
);

export default Button;
