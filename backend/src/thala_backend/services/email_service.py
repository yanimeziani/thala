"""Email service for sending emails via SMTP."""
import smtplib
import ssl
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
from typing import List, Optional

from ..core.config import settings


class EmailService:
    """Service for sending emails via SMTP."""

    @staticmethod
    def send_email(
        to_email: str | List[str],
        subject: str,
        html_body: str,
        text_body: Optional[str] = None,
        from_email: Optional[str] = None,
        from_name: Optional[str] = None,
    ) -> bool:
        """
        Send an email via SMTP.

        Args:
            to_email: Recipient email address or list of addresses
            subject: Email subject
            html_body: HTML email body
            text_body: Plain text email body (optional)
            from_email: Sender email (defaults to SMTP_FROM_EMAIL)
            from_name: Sender name (defaults to SMTP_FROM_NAME)

        Returns:
            bool: True if email was sent successfully, False otherwise
        """
        if not settings.smtp_host or not settings.smtp_password:
            print("SMTP not configured. Skipping email send.")
            return False

        # Normalize to_email to list
        recipients = [to_email] if isinstance(to_email, str) else to_email

        # Use default sender if not provided
        sender_email = from_email or settings.smtp_from_email
        sender_name = from_name or settings.smtp_from_name

        # Create message
        message = MIMEMultipart("alternative")
        message["Subject"] = subject
        message["From"] = f"{sender_name} <{sender_email}>"
        message["To"] = ", ".join(recipients)

        # Add text and HTML parts
        if text_body:
            text_part = MIMEText(text_body, "plain")
            message.attach(text_part)

        html_part = MIMEText(html_body, "html")
        message.attach(html_part)

        try:
            # Create SSL context
            context = ssl.create_default_context()

            # Connect to SMTP server
            with smtplib.SMTP_SSL(
                settings.smtp_host,
                settings.smtp_port,
                context=context,
            ) as server:
                # Login
                server.login(settings.smtp_user or "resend", settings.smtp_password)

                # Send email
                server.sendmail(sender_email, recipients, message.as_string())

            print(f"Email sent successfully to {recipients}")
            return True

        except Exception as e:
            print(f"Failed to send email: {e}")
            return False

    @staticmethod
    def send_welcome_email(user_email: str, user_name: str) -> bool:
        """Send welcome email to new user."""
        html_body = f"""
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
        </head>
        <body style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px;">
            <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 30px; border-radius: 10px 10px 0 0; text-align: center;">
                <h1 style="color: white; margin: 0;">Welcome to Thala! 🎉</h1>
            </div>
            <div style="background: #f9fafb; padding: 30px; border-radius: 0 0 10px 10px;">
                <p style="font-size: 16px;">Hello {user_name},</p>
                <p style="font-size: 16px;">Welcome to Thala - your hub for Amazigh culture! We're excited to have you join our community.</p>
                <p style="font-size: 16px;">Explore cultural heritage, connect with others, and celebrate the rich traditions of Amazigh culture.</p>
                <div style="margin: 30px 0; text-align: center;">
                    <a href="https://thala.app" style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 12px 30px; text-decoration: none; border-radius: 6px; display: inline-block; font-weight: 600;">Get Started</a>
                </div>
                <p style="font-size: 14px; color: #6b7280;">If you have any questions, feel free to reach out to our support team.</p>
                <hr style="border: none; border-top: 1px solid #e5e7eb; margin: 30px 0;">
                <p style="font-size: 12px; color: #9ca3af; text-align: center;">© 2025 Thala. All rights reserved.</p>
            </div>
        </body>
        </html>
        """

        text_body = f"""
        Welcome to Thala!

        Hello {user_name},

        Welcome to Thala - your hub for Amazigh culture! We're excited to have you join our community.

        Explore cultural heritage, connect with others, and celebrate the rich traditions of Amazigh culture.

        Visit us at: https://thala.app

        If you have any questions, feel free to reach out to our support team.

        © 2025 Thala. All rights reserved.
        """

        return EmailService.send_email(
            to_email=user_email,
            subject="Welcome to Thala! 🎉",
            html_body=html_body,
            text_body=text_body,
        )

    @staticmethod
    def send_password_reset_email(user_email: str, reset_link: str) -> bool:
        """Send password reset email."""
        html_body = f"""
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
        </head>
        <body style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px;">
            <div style="background: #f9fafb; padding: 30px; border-radius: 10px;">
                <h1 style="color: #667eea; margin-top: 0;">Password Reset Request</h1>
                <p style="font-size: 16px;">You requested to reset your password.</p>
                <p style="font-size: 16px;">Click the button below to reset your password:</p>
                <div style="margin: 30px 0; text-align: center;">
                    <a href="{reset_link}" style="background: #667eea; color: white; padding: 12px 30px; text-decoration: none; border-radius: 6px; display: inline-block; font-weight: 600;">Reset Password</a>
                </div>
                <p style="font-size: 14px; color: #6b7280;">This link will expire in 1 hour.</p>
                <p style="font-size: 14px; color: #6b7280;">If you didn't request this, please ignore this email.</p>
                <hr style="border: none; border-top: 1px solid #e5e7eb; margin: 30px 0;">
                <p style="font-size: 12px; color: #9ca3af; text-align: center;">© 2025 Thala. All rights reserved.</p>
            </div>
        </body>
        </html>
        """

        text_body = f"""
        Password Reset Request

        You requested to reset your password.

        Click the link below to reset your password:
        {reset_link}

        This link will expire in 1 hour.

        If you didn't request this, please ignore this email.

        © 2025 Thala. All rights reserved.
        """

        return EmailService.send_email(
            to_email=user_email,
            subject="Reset Your Thala Password",
            html_body=html_body,
            text_body=text_body,
        )

    @staticmethod
    def send_notification_email(
        user_email: str,
        notification_type: str,
        message: str,
        action_url: Optional[str] = None,
    ) -> bool:
        """Send notification email to user."""
        html_body = f"""
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="utf-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
        </head>
        <body style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; padding: 20px;">
            <div style="background: #f9fafb; padding: 30px; border-radius: 10px;">
                <h1 style="color: #667eea; margin-top: 0;">{notification_type}</h1>
                <p style="font-size: 16px;">{message}</p>
                {f'<div style="margin: 30px 0; text-align: center;"><a href="{action_url}" style="background: #667eea; color: white; padding: 12px 30px; text-decoration: none; border-radius: 6px; display: inline-block; font-weight: 600;">View Details</a></div>' if action_url else ''}
                <hr style="border: none; border-top: 1px solid #e5e7eb; margin: 30px 0;">
                <p style="font-size: 12px; color: #9ca3af; text-align: center;">© 2025 Thala. All rights reserved.</p>
            </div>
        </body>
        </html>
        """

        text_body = f"""
        {notification_type}

        {message}

        {f'View details: {action_url}' if action_url else ''}

        © 2025 Thala. All rights reserved.
        """

        return EmailService.send_email(
            to_email=user_email,
            subject=notification_type,
            html_body=html_body,
            text_body=text_body,
        )


# Singleton instance
email_service = EmailService()
