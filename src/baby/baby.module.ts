import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { BabyService } from './baby.service';
import { BabyController } from './baby.controller';
import { Baby } from './baby.entity';
import { User } from '../user/user.entity';

@Module({
  imports: [TypeOrmModule.forFeature([Baby, User])],
  controllers: [BabyController],
  providers: [BabyService],
})
export class BabyModule {}
