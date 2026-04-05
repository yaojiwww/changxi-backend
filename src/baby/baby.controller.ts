import {
  Controller,
  Get,
  Post,
  Body,
  Patch,
  Param,
  Delete,
  Query,
  Put,
} from '@nestjs/common';
import { BabyService } from './baby.service';
import { CreateBabyDto } from './dto/create-baby.dto';
import { UpdateBabyDto } from './dto/update-baby.dto';

@Controller('baby')
export class BabyController {
  constructor(private readonly babyService: BabyService) {}

  @Post()
  create(@Body() createBabyDto: CreateBabyDto) {
    return this.babyService.create(createBabyDto);
  }

  @Get()
  findAll() {
    return this.babyService.findAll();
  }

  @Get('user/:userId')
  findByUserId(@Param('userId') userId: string) {
    return this.babyService.findByUserId(+userId);
  }

  @Get(':id')
  findOne(@Param('id') id: string) {
    return this.babyService.findOne(+id);
  }

  @Put(':id')
  update(@Param('id') id: string, @Body() updateBabyDto: UpdateBabyDto) {
    return this.babyService.update(+id, updateBabyDto);
  }

  @Delete(':id')
  remove(@Param('id') id: string) {
    return this.babyService.remove(+id);
  }
}
