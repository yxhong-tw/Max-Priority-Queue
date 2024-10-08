module MPQ(
    clk,
    rst,
    data_valid,
    data,
    cmd_valid,
    cmd,
    index,
    value,
    busy,
    RAM_valid,
    RAM_A,
    RAM_D,
    done
);

    input clk;
    input rst;
    input data_valid;
    input [7:0] data;
    input cmd_valid;
    input [2:0] cmd;
    input [7:0] index;
    input [7:0] value;

    output reg busy;
    output reg RAM_valid;
    output reg [7:0] RAM_A;
    output reg [7:0] RAM_D;
    output reg done;

    parameter [3:0] IDLE = 4'd0;
    parameter [3:0] READ = 4'd1;
    parameter [3:0] BUILD_QUEUE = 4'd2;
    parameter [3:0] MH_COMPARE = 4'd3;
    parameter [3:0] MH_RECURSE = 4'd4;
    parameter [3:0] EXTRACT_MAX = 4'd5;
    parameter [3:0] INCREASE_VALUE = 4'd6;
    parameter [3:0] INSERT_DATA = 4'd7;
    parameter [3:0] WRITE = 4'd8;

    reg [3:0] state;
    reg [3:0] next_state;

    // READ
    reg R_done;

    // BUILD_QUEUE
    reg initialized_i;
    reg do_MH;
    reg BQ_done;

    // MAX_HEAPIFY
    reg [4:0] i;
    reg [4:0] _i;
    reg [4:0] l;
    reg [4:0] r;
    reg [4:0] largest;
    reg [7:0] temp_data;
    reg MH_COMPARE_done;
    reg MH_RECURSE_done;
    reg MH_done;

    // EXTRACT_MAX
    reg EXTRACT_MAX_done;

    // INCREASE_VALUE
    reg INCREASE_VALUE_done;

    // INSERT_DATA
    reg INSERT_DATA_done;

    // WRITE
    reg initialized_tree_counter;

    reg [4:0] tree_counter;
    reg [4:0] tree_data_number;
    reg [7:0] tree [0:31];

    integer loop_idx;

    always @(posedge clk or posedge rst) begin
        if (rst) begin
            busy <= 0;
            RAM_valid <= 0;
            RAM_A <= 0;
            RAM_D <= 0;
            done <= 0;

            state <= IDLE;

            // READ
            R_done <= 0;

            // BUILD_QUEUE
            initialized_i <= 0;
            do_MH <= 0;
            BQ_done <= 0;

            // MAX_HEAPIFY
            i <= -1;
            _i <= -1;
            l <= -1;
            r <= -1;
            largest <= -1;
            temp_data <= 0;
            MH_COMPARE_done <= 0;
            MH_RECURSE_done <= 0;
            MH_done <= 0;

            // EXTRACT_MAX
            EXTRACT_MAX_done <= 0;

            // INCREASE_VALUE
            INCREASE_VALUE_done <= 0;

            // INSERT_DATA
            INSERT_DATA_done <= 0;

            // WRITE
            initialized_tree_counter <= 0;

            tree_counter <= 0;
            tree_data_number <= 0;
            for (loop_idx = 0; loop_idx < 32; loop_idx = loop_idx + 1) begin
                tree[loop_idx] <= 0;
            end
        end else begin
            state = next_state;

            case (state)
                IDLE: begin
                    busy <= 0;

                    // READ
                    R_done <= 0;

                    // BUILD_QUEUE
                    initialized_i <= 0;
                    do_MH <= 0;
                    BQ_done <= 0;

                    // MAX_HEAPIFY
                    i <= -1;
                    _i <= -1;
                    l <= -1;
                    r <= -1;
                    largest <= -1;
                    temp_data <= 0;
                    MH_COMPARE_done <= 0;
                    MH_RECURSE_done <= 0;
                    MH_done <= 0;

                    // EXTRACT_MAX
                    EXTRACT_MAX_done <= 0;

                    // INCREASE_VALUE
                    INCREASE_VALUE_done <= 0;

                    // INSERT_DATA
                    INSERT_DATA_done <= 0;

                    loop_idx <= 0;
                end
                READ: begin
                    busy <= 1;

                    if (data_valid) begin
                        tree[tree_data_number] <= data;
                        tree_data_number <= tree_data_number + 1;
                    end else begin
                        R_done <= 1;
                    end
                end
                BUILD_QUEUE: begin
                    busy <= 1;

                    if (initialized_i == 0) begin
                        i = (tree_data_number - 1) / 2;
                        _i = i;

                        initialized_i <= 1;
                        do_MH <= 1;
                    end else if (i > 0 && largest == _i) begin
                        i = i - 1;
                        _i = i;
                    end else if (i == 0 && largest == _i) begin
                        do_MH <= 0;
                        BQ_done <= 1;
                    end
                end
                MH_COMPARE: begin
                    MH_RECURSE_done = 0;

                    l = 2 * (_i + 1) - 1;
                    r = 2 * (_i + 1);
                    largest = _i;

                    if (l < tree_data_number && tree[l] > tree[_i]) begin
                        largest = l;
                    end else begin
                        largest = _i;
                    end

                    if (r < tree_data_number && tree[r] > tree[largest]) begin
                        largest = r;
                    end

                    if (largest != _i) begin
                        temp_data = tree[_i];
                        tree[_i] = tree[largest];
                        tree[largest] = temp_data;

                        MH_COMPARE_done = 1;
                    end else begin
                        MH_done = 1;
                    end
                end
                MH_RECURSE: begin
                    MH_COMPARE_done <= 0;

                    _i <= largest;

                    MH_RECURSE_done <= 1;
                end
                EXTRACT_MAX: begin
                    busy <= 1;

                    tree[0] = tree[tree_data_number - 1];
                    tree_data_number = tree_data_number - 1;

                    EXTRACT_MAX_done = 1;
                end
                INCREASE_VALUE: begin
                    busy <= 1;

                    tree[index] = value;

                    INCREASE_VALUE_done = 1;
                end
                INSERT_DATA: begin
                    busy <= 1;

                    tree[tree_data_number] = value;
                    tree_data_number = tree_data_number + 1;

                    INSERT_DATA_done = 1;
                end
                WRITE: begin
                    busy <= 1;

                    if (initialized_tree_counter == 0) begin
                        tree_counter <= 0;
                        initialized_tree_counter <= 1;
                    end else if (tree_counter < tree_data_number) begin
                        RAM_valid <= 1;
                        RAM_A <= tree_counter;
                        RAM_D <= tree[tree_counter];

                        tree_counter = tree_counter + 5'b00001;
                    end else begin
                        done <= 1;
                    end
                end
            endcase
        end
    end

    always @(*) begin
        next_state = state;

        case (state)
            IDLE: begin
                if (data_valid) begin
                    next_state <= READ;
                end else if (cmd_valid) begin
                    if (cmd == 3'b000) begin
                        next_state <= BUILD_QUEUE;
                    end else if (cmd == 3'b001) begin
                        next_state <= EXTRACT_MAX;
                    end else if (cmd == 3'b010) begin
                        next_state <= INCREASE_VALUE;
                    end else if (cmd == 3'b011) begin
                        next_state <= INSERT_DATA;
                    end else if (cmd == 3'b100) begin
                        next_state <= WRITE;
                    end
                end
            end
            READ: begin
                if (R_done) begin
                    next_state <= IDLE;
                end
            end
            BUILD_QUEUE: begin
                if (do_MH) begin
                    next_state <= MH_COMPARE;
                end else if (BQ_done) begin
                    next_state <= IDLE;
                end
            end
            MH_COMPARE: begin
                if (MH_COMPARE_done) begin
                    next_state <= MH_RECURSE;
                end else if (MH_done) begin
                    if (do_MH) begin
                        next_state <= BUILD_QUEUE;
                    end else begin
                        next_state <= IDLE;
                    end
                end
            end
            MH_RECURSE: begin
                if (MH_RECURSE_done) begin
                    next_state <= MH_COMPARE;
                end
            end
            EXTRACT_MAX: begin
                if (EXTRACT_MAX_done) begin
                    next_state <= BUILD_QUEUE;
                end
            end
            INCREASE_VALUE: begin
                if (INCREASE_VALUE_done) begin
                    next_state <= BUILD_QUEUE;
                end
            end
            INSERT_DATA: begin
                if (INSERT_DATA_done) begin
                    next_state <= BUILD_QUEUE;
                end
            end
            WRITE: begin
                if (done) begin
                    next_state <= IDLE;
                end
            end
        endcase
    end
endmodule
