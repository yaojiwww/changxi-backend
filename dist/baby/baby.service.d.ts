import { Repository } from 'typeorm';
import { CreateBabyDto } from './dto/create-baby.dto';
import { UpdateBabyDto } from './dto/update-baby.dto';
import { Baby } from './baby.entity';
import { User } from '../user/user.entity';
export declare class BabyService {
    private babyRepository;
    private userRepository;
    constructor(babyRepository: Repository<Baby>, userRepository: Repository<User>);
    create(createBabyDto: CreateBabyDto): Promise<Baby>;
    findAll(): Promise<Baby[]>;
    findOne(id: number): Promise<Baby | null>;
    findByUserId(userId: number): Promise<any[]>;
    update(id: number, updateBabyDto: UpdateBabyDto): Promise<Baby | null>;
    remove(id: number): Promise<void>;
}
