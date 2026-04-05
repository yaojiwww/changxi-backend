import { PartialType } from '@nestjs/mapped-types';
import { CreateBabyDto } from './create-baby.dto';

export class UpdateBabyDto extends PartialType(CreateBabyDto) {}
