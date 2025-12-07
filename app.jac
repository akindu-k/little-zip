import pygame;
import sys;
import custom_sysfont;

import from byllm.lib{Model}

glob GENERAL_FONT = '8bitoperator_jve.ttf';
glob llm = Model(model_name="gemini/gemini-2.0-flash");




walker game{

    has game_state:str = "welcome";
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
    has drawing:bool = False;
    has next_number:int = 2;

    has bg_color:tuple[int, int, int] = (255,255,255);
    has grid_color:tuple[int, int, int] = (0,0,0);
    has path_color:tuple[int, int, int] = (0,200,0);
    has error_color:tuple[int, int, int] = (200,0,0);
    has text_color:tuple[int, int, int] = (200,0,0);

        """
        Generates a solvable Hamiltonian path puzzle using AI.
        
        This creates a 5x5 grid puzzle that is fundamentally a Hamiltonian path problem:
        - A Hamiltonian path must visit every cell in the grid exactly once
        - Numbers 1-10 are randomly placed as waypoints that must be visited in sequential order
        - Empty cells (0) represent intermediate nodes in the path
        - The path must connect all numbered cells (1→2→3→...→10) while filling all empty squares
        - Movement is restricted to horizontal/vertical only (4-connected grid graph)
        
        The AI ensures that:
        1. A valid Hamiltonian path exists from cell 1 to cell 10
        2. The path visits all 25 cells exactly once
        3. All numbered waypoints can be reached in the correct sequence
        4. The puzzle has exactly one valid solution
        
        Returns:
            str: A string representation of a 5x5 grid with newline separators
                Format: "1, 0, 0, 0, 7\n0, 0, 0, 6, 0\n0, 3, 4, 0, 8\n2, 0, 0, 0, 9\n0, 0, 0, 5, 10"
                
        Mathematical properties:
            - Graph: 5x5 grid (25 vertices, 4-connected)
            - Problem: Hamiltonian path with ordered waypoint constraints
            - Constraint: Path must visit numbered cells in ascending order
            - Guarantee: Exactly one valid solution exists
        """
    def level_generator() -> str by llm();

    def draw_welcome_screen(){
        self.screen.fill(self.bg_color);
        
        # Title
        title_text = self.font.render("LITTLE ZIP", True, self.text_color);
        title_rect = title_text.get_rect(center=(250, 80));
        self.screen.blit(title_text, title_rect);
        
        # Instructions
        instructions = [
            "HOW TO PLAY:",
            "",
            "1. Click on cell '1' to start",
            "2. Draw path through numbers 2-10",
            "3. Fill all empty squares",
            "4. Only move horizontally/vertically",
            "5. Can't revisit squares",
            "",
            "CONTROLS:",
            "- Mouse: Draw path",
            "- R: Reset game",
            "",
            "PRESS SPACE TO START"
        ];
        
        y_offset = 140;
        for instruction in instructions{
            if instruction == ""{
                y_offset += 20;
                continue;
            }
            text = self.small_font.render(instruction, True, self.text_color);
            text_rect = text.get_rect(center=(250, y_offset));
            self.screen.blit(text, text_rect);
            y_offset += 25;
        }
    }
    

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

    def draw_msg(msg:str){
        text = self.font.render(msg, True, self.text_color);

        cx = 250;
        cy = 250;

        text_rect = text.get_rect(center=(cx, cy));
        self.screen.blit(text, text_rect);
    }

    def all_squares_filled() -> bool{
        for row in range(self.rows){
            for col in range(self.cols){
                if (not self.visited[row][col]){
                    return False;
                }
            }
        }
        print("All squares filled");
        return True;
    }

    def reset_game(){
        
        self.path_cells.clear();
        self.error_cells.clear();
        self.path_active = False;
        self.drawing = False;
        self.next_number = 2;
        self.game_completed = False;
        
        
        for i in range(self.rows){
            for j in range(self.cols){
                self.visited[i][j] = False;
            }
        }
    }



    can start with `root entry
    {
        pygame.init("little zip");
        self.font = custom_sysfont.SysFont("8bitoperator_jve", 32);
        self.small_font = custom_sysfont.SysFont("8bitoperator_jve", 18);
        self.screen = pygame.display.set_mode((500, 500));
        self.clock = pygame.time.Clock();
        self.game_completed = False;
        running = True;

        # self.level = self.level_generator();
        print("Generated Level:",self.level_generator());

        for i in range(self.rows){
            row_list = [];
            for j in range(self.cols){
                row_list.append(False);
            }
            self.visited.append(row_list);
        }

        while (running)
        {
            for event in pygame.event.get()
            {
                if (event.type == pygame.QUIT)
                {
                    running = False;
                }
                
                elif (event.type == pygame.KEYDOWN)
                {
                    if (event.key == pygame.K_SPACE and self.game_state == "welcome")
                    {
                        self.game_state = "playing";
                    }
                    elif (event.key == pygame.K_r)
                    {
                        if (self.game_state == "playing" or self.game_state == "completed")
                        {
                            self.reset_game();
                            self.game_state = "playing";
                        }
                    }
                    elif (event.key == pygame.K_ESCAPE)
                    {
                        self.game_state = "welcome";
                        self.reset_game();
                    }
                }

                elif (event.type == pygame.MOUSEBUTTONDOWN and event.button == 1 and self.game_state == "playing")
                {
                    (mx, my) = pygame.mouse.get_pos();
                    col = mx // self.cell_size;
                    row = my // self.cell_size;

                    if (not self.path_active)
                    {
                        if (0 <= col < self.cols and 0 <= row < self.rows and self.level[row][col] == 1)
                        {
                            self.path_cells = [(col, row)];
                            self.visited[row][col] = True;      
                            self.path_active = True;
                            self.drawing = True;
                            self.next_number = 2;
                            self.error_cells.clear();
                        }
                    }
                    else
                    {
                        if (len(self.path_cells) > 0)
                        {
                            (last_col, last_row) = self.path_cells[-1];
                            if (0 <= col < self.cols and 0 <= row < self.rows and col == last_col and row == last_row)
                            {
                                self.drawing = True;
                            }
                        }
                    }
                }
                elif (event.type == pygame.MOUSEMOTION and self.path_active and self.game_state == "playing")
                {
                    (mx,my) = pygame.mouse.get_pos();
                    col = mx // self.cell_size;
                    row = my // self.cell_size;
                    if (0 <= col < self.cols and 0 <= row < self.rows)
                    {
                        (last_col, last_row) = self.path_cells[-1];
                        if ((col,row) != (last_col, last_row))
                        {
                            col_diff = int(col - last_col);
                            row_diff = int(row - last_row);
                            abs_col_diff = col_diff if col_diff >= 0 else -col_diff;
                            abs_row_diff = row_diff if row_diff >= 0 else -row_diff; 
                            if ((abs_col_diff + abs_row_diff) == 1)
                            {
                                if (not self.visited[row][col])
                                {
                                    cell_val = self.level[row][col];
                                    if ((cell_val == 0) or (cell_val == self.next_number))
                                    {
                                        self.path_cells.append((col, row));
                                        self.visited[row][col] = True;
                                        if (cell_val == self.next_number)
                                        {
                                            self.next_number += 1;
                                            print(self.next_number);

                                            if (self.next_number == 11)
                                            {
                                                self.game_completed = True;
                                                self.path_active = False;
                                                self.game_state = "completed";
                                            }
                                        }
                                                                                      
                                    }
                                    else
                                    {
                                        self.error_cells.append((col, row));
                                    }
                                }
                                else
                                {
                                    self.error_cells.append((col, row));
                                }
                            }
                            else
                            {
                                self.error_cells.append((col, row));
                            }
                            }
                        }
                }
                
                elif (event.type == pygame.MOUSEBUTTONUP and event.button == 1 and self.game_state == "playing")
                {
                    self.drawing = False;
                }
            }

            if (self.game_state == "welcome")
            {
                self.draw_welcome_screen();
            }
            elif (self.game_state == "playing")
            {
                self.draw_grid();
                self.draw_path();
            }
            elif (self.game_state == "completed")
            {
                if (not self.all_squares_filled())
                {
                    self.screen.fill(self.bg_color);
                    self.draw_msg("Fill all squares!");
                }
                else
                {
                    self.screen.fill(self.bg_color);
                    self.draw_msg("Congratulations!");
                }
            }

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