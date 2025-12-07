import pygame;
import sys;

walker game{
    has cell_size:int = 100;
    has cols:int = 5;
    has rows:int = 5;


    has level:List[List[int]] = [
        [ 1,  0,  0,  0,  7],
        [ 0,  0,  0,  6,  0],
        [ 0,  3,  4,  0,  8],
        [ 2,  0,  0,  0,  9],
        [ 0,  0,  0,  5, 10]
    ];

    has visited:List[List[bool]] = [];
    has path_cells:List[Tuple[int, int]] = [];
    has error_cells:List[Tuple[int, int]] = [];  
    has path_active:bool = False;  
    has next_number:int = 2;

    has bg_color:tuple[int, int, int] = (255,255,255);
    has grid_color:tuple[int, int, int] = (0,0,0);
    has path_color:tuple[int, int, int] = (0,200,0);
    has error_color:tuple[int, int, int] = (200,0,0);
    has text_color:tuple[int, int, int] = (0,0,0);
    

    def draw_grid(){
        self.screen.fill(self.bg_color);
        for row in range(self.rows){
            for col in range(self.cols){
                x = col * self.cell_size;
                y = row * self.cell_size;
                rect = pygame.Rect(x, y, self.cell_size, self.cell_size);

                if (col,row) in self.path_cells{
                    pygame.draw.rect(self.screen,(220,255,220),rect);
                }

                if (col,row) in self.error_cells{
                    pygame.draw.rect(self.screen,(255,220,220),rect);
                }

                pygame.draw.rect(self.screen,self.grid_color,rect,1);

                num = self.level[row][col];

                if (num != 0){
                    text = self.font.render(str(num), True, self.text_color);
                    text_rect = text.get_rect(center=(x + self.cell_size/2, y + self.cell_size/2));
                    self.screen.blit(text, text_rect);
                }
            }
        }
    }

    def draw_path(){
        if (len(self.path_cells) > 1){
            points = [];
            for (col,row) in self.path_cells{
            cx = col * self.cell_size + self.cell_size // 2;
            cy = row * self.cell_size + self.cell_size // 2;
            points.append((cx, cy));
            }
            pygame.draw.lines(self.screen, self.path_color, False, points, 5);
        }
    }

    can start with `root entry{
        pygame.init("little zip");
        # pygame.font.init("little zip"); 
        
        self.screen = pygame.display.set_mode((500, 500));
        self.clock = pygame.time.Clock();
        self.font = pygame.font.Font(None, 32);
        # self.fnt: pygame.font.Font = pygame.font.Font(GENERAL_FONT, 32);
        running = True;

        for i in range(self.rows){
        row_list = [];
        for j in range(self.cols){
            row_list.append(False);
        }
        self.visited.append(row_list);
        }

        while (running){
            for event in pygame.event.get(){
                if (event.type == pygame.QUIT){
                    running = False;
                }

                elif (event.type == pygame.MOUSEBUTTONDOWN and event.button == 1){
                    (mx, my) = pygame.mouse.get_pos();
                    col = mx // self.cell_size;
                    row = my // self.cell_size;

                    if (0 <= col < self.cols and 0 <= row < self.rows){
                        # Check if this is the starting cell (value 1) and path is empty
                        if (len(self.path_cells) == 0){
                            if (self.level[row][col] == 1){
                                self.path_cells.append((col, row));
                                self.visited[row][col] = True;
                                self.path_active = True;
                            }
                        }
                        # Handle subsequent cells if path has started and is active
                        elif (self.path_active and len(self.path_cells) > 0){
                            (last_col, last_row) = self.path_cells[-1];

                            if ((col, row) != (last_col, last_row)){
                                col_diff = int(col - last_col);
                                row_diff = int(row - last_row);

                                abs_col_diff = col_diff if col_diff >= 0 else -col_diff;
                                abs_row_diff = row_diff if row_diff >= 0 else -row_diff;  
                                if ((abs_col_diff + abs_row_diff) == 1){
                                    if (not self.visited[row][col]){
                                        cell_val = self.level[row][col];
                                        if (cell_val == 0 or cell_val == self.next_number){
                                            self.path_cells.append((col, row));
                                            self.visited[row][col] = True;
                                            if (cell_val == self.next_number){
                                                self.next_number += 1;
                                            }
                                        }
                                        else{
                                            self.error_cells.append((col, row));
                                        }
                                    }
                                    else{
                                        self.error_cells.append((col, row));
                                    }
                                }else{
                                    self.error_cells.append((col, row));
                                }
                            }
                        }
                    }
                }
                elif (event.type == pygame.MOUSEBUTTONUP and event.button == 1){
                    self.path_active = False;
                }
            }
            self.draw_grid();
            self.draw_path();
            pygame.display.flip();
            self.clock.tick(30);
        }
        pygame.quit();
        sys.exit();

    }
}

with entry{
    root spawn game();
}