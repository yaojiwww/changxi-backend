import { UserService } from './user.service';
import { CreateUserDto } from './dto/create-user.dto';
import { UpdateUserDto } from './dto/update-user.dto';
export declare class UserController {
    private readonly userService;
    constructor(userService: UserService);
    create(createUserDto: CreateUserDto): Promise<import("./user.entity").User>;
    findAll(): Promise<import("./user.entity").User[]>;
    findOne(id: string): Promise<import("./user.entity").User | null>;
    update(id: string, updateUserDto: UpdateUserDto): Promise<import("./user.entity").User | null>;
    remove(id: string): Promise<void>;
    setCurrentBaby(id: string, babyId: number): Promise<import("./user.entity").User | null>;
}
