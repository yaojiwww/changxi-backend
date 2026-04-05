import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
} from 'typeorm';

@Entity('user')
export class User {
  @PrimaryGeneratedColumn()
  id!: number;

  @Column({ length: 20, name: 'phone_number' })
  phoneNumber!: string;

  @Column({ length: 50, name: 'account_name' })
  accountName!: string;

  @Column({ length: 255, nullable: true })
  email?: string;

  @Column({ length: 100, name: 'password_hash', nullable: true })
  passwordHash?: string;

  @Column({ length: 255, name: 'avatar_url', nullable: true })
  avatarUrl?: string;

  @Column({ name: 'current_baby_id', nullable: true })
  currentBabyId?: number;

  @CreateDateColumn({ name: 'create_at' })
  createAt!: Date;

  @UpdateDateColumn({ name: 'update_at' })
  updateAt!: Date;
}


