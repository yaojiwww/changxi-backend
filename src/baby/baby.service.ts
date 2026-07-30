import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { CreateBabyDto } from './dto/create-baby.dto';
import { UpdateBabyDto } from './dto/update-baby.dto';
import { Baby } from './baby.entity';
import { User } from '../user/user.entity';

@Injectable()
export class BabyService {
  constructor(
    @InjectRepository(Baby)
    private babyRepository: Repository<Baby>,
    @InjectRepository(User)
    private userRepository: Repository<User>,
  ) {}

  async create(createBabyDto: CreateBabyDto): Promise<Baby> {
    const baby = new Baby();
    Object.assign(baby, createBabyDto);
    return this.babyRepository.save(baby);
  }

  async findAll(): Promise<Baby[]> {
    return this.babyRepository.find();
  }

  async findOne(id: number): Promise<Baby | null> {
    return this.babyRepository.findOne({ where: { id } });
  }

  async findByUserId(userId: number): Promise<any[]> {
    const babies = await this.babyRepository.find({ where: { userId } });
    const user = await this.userRepository.findOne({ where: { id: userId } });
    const currentBabyId = user?.currentBabyId;

    return babies.map((baby) => ({
      ...baby,
      isCurrent: baby.id === currentBabyId,
    }));
  }

  async update(id: number, updateBabyDto: UpdateBabyDto): Promise<Baby | null> {
    // 排除不允许更新的字段
    const { userId, ...rest } = updateBabyDto as any;
    await this.babyRepository.update(id, rest);
    return this.findOne(id);
  }

  async remove(id: number): Promise<void> {
    await this.babyRepository.delete(id);
  }
}
