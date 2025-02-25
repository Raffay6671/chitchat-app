interface RegistrationData {
    username: string;
    email: string;
    password: string;
  }
  
  export const validateRegistrationData = (data: RegistrationData): string[] => {
    const errors: string[] = [];
  
    // Validate username (at least 3 characters)
    if (!data.username || data.username.length < 3) {
      errors.push('Username must be at least 3 characters long.');
    }
  
    // Validate email using regex
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(data.email)) {
      errors.push('Invalid email format.');
    }
  
    // Validate password (minimum 6 characters, one uppercase, one lowercase, one digit)
    const passwordRegex = /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d).{6,}$/;
    if (!passwordRegex.test(data.password)) {
      errors.push('Password must be at least 6 characters long and contain uppercase, lowercase, and a number.');
    }
  
    return errors;
  };
  