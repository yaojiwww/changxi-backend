export class CreateBabyDto {
  userId: number;
  babyName: string;
  gender: number;
  birthDate: string;
  height?: number;
  weight?: number;
  bloodType?: number;
  avatarUrl?: string;
}
