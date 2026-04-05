import { BabyService } from './baby.service';
import { CreateBabyDto } from './dto/create-baby.dto';
import { UpdateBabyDto } from './dto/update-baby.dto';
export declare class BabyController {
    private readonly babyService;
    constructor(babyService: BabyService);
    create(createBabyDto: CreateBabyDto): Promise<import("./baby.entity").Baby>;
    findAll(): Promise<import("./baby.entity").Baby[]>;
    findByUserId(userId: string): Promise<any[]>;
    findOne(id: string): Promise<import("./baby.entity").Baby | null>;
    update(id: string, updateBabyDto: UpdateBabyDto): Promise<import("./baby.entity").Baby | null>;
    remove(id: string): Promise<void>;
}
