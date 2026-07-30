export class CreateUserDto {
  phoneNumber: string;
  accountName: string;
  email?: string;
  passwordHash?: string;
  avatarUrl?: string;
}
