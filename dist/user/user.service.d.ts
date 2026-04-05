import { Repository } from 'typeorm';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
import { User } from './user.entity';
export declare class UserService {
    private userRepository;
    constructor(userRepository: Repository<User>);
    create(createUserDto: CreateUserDto): Promise<User>;
    findAll(): Promise<User[]>;
    findOne(id: number): Promise<User | null>;
    update(id: number, updateUserDto: UpdateUserDto): Promise<User | null>;
    remove(id: number): Promise<void>;
    setCurrentBaby(userId: number, babyId: number): Promise<User | null>;
}
