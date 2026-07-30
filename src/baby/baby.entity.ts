import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';

@Entity('baby')
export class Baby {
  @PrimaryGeneratedColumn()
  id!: number;

  @Column({ name: 'user_id' })
  userId!: number;

  @Column({ length: 50, name: 'baby_name' })
  babyName!: string;

  @Column({ type: 'tinyint', name: 'gender' })
  gender!: number;

  @Column({ type: 'date', name: 'birth_date' })
  birthDate!: Date;

  @Column({ type: 'float', nullable: true })
  height?: number;

  @Column({ type: 'float', nullable: true })
  weight?: number;

  @Column({ type: 'tinyint', name: 'blood_type', nullable: true })
  bloodType?: number;

  @Column({ length: 255, name: 'avatar_url', nullable: true })
  avatarUrl?: string;

  @CreateDateColumn({ name: 'create_at' })
  createAt!: Date;

  @UpdateDateColumn({ name: 'update_at' })
  updateAt!: Date;
}
