`timescale 1ns / 1ps
module example(
    input clk,
    input [7:0] sw,
    input rxd,
    input btn,
    output [7:0] led,
    output reg [2:0] an,
    output reg [3:0] d,
    output txd,
    output sck,
	output mosi,
	input miso
    );

reg clear =0;
reg state,state_r1,state_r2 = 0;
reg [26:0] cnt = 0;
reg [3:0] dr[7:0];
wire state_redge;
reg btn_prev;  // �����洢��һ�ΰ�ť��״̬
parameter PSPI_WIDTH = 1;
parameter YELLOW = 16'hE0FF;  // ��ɫRGB565��ʽ
parameter RED = 16'h00F8;     // ��ɫRGB565��ʽ
parameter YELLOW32 = 32'hE0FFE0FF;  // �����ػ�ɫRGB565��ʽ
parameter RED32 = 32'h00F800F8;     // �����غ�ɫRGB565��ʽ

assign led = sw;  
assign txd = rxd;

reg [31:0] pspi_a;
reg [31:0] pspi_d;
reg pspi_we;
reg pspi_rd;
wire [31:0] pspi_spo;
wire pspi_ready;

reg write_in_progress = 0;   // ��־��ǰ�Ƿ���д�����
reg read_in_progress = 0;

// �������
wire [31:0] mouse_xy;
reg [31:0] mouse_data;
wire [15:0] mouse_x, mouse_y;
wire [31:0] mouse_addr;

assign mouse_xy = {pspi_spo[7:0], pspi_spo[15:8], pspi_spo[23:16], pspi_spo[31:24]};
assign mouse_x = mouse_xy[31:16];
assign mouse_y = mouse_xy[15:0];
assign mouse_addr = (mouse_y * 320 + mouse_x) * 2;

// ��ⰴť��������
always @(posedge clk) begin
    btn_prev <= btn;  // ������һ�ΰ�ť��״̬
    if (!btn_prev && btn)  // �����һ�ΰ�ť�ǵͣ�����Ǹߣ���ʾ��⵽������
        clear <= 1'b1;  // ���������־
    else
        clear <= 1'b0;  // ��������־
end

always@(posedge clk)
begin
  if (cnt >= 100000000)
    cnt <= 0;
  else
    cnt <= cnt + 1;
end

always@(posedge clk)
begin
    if (cnt[26:19]) state <= 1;
    else state <= 0;
    state_r1 <= state;
    state_r2 <= state_r1;
end

assign state_redge = state_r1 & (~state_r2);

always@(posedge clk)
begin
    if (clear)
    begin
        dr[0] <= 0;
        dr[1] <= 0;
        dr[2] <= 0;
        dr[3] <= 0;
        dr[4] <= 0;
        dr[5] <= 0;
        dr[6] <= 0;
        dr[7] <= 0;
    end
    else if(state_redge)
    begin
        dr[0] <= dr[0]+1;
        dr[1] <= dr[0];
        dr[2] <= dr[1];
        dr[3] <= dr[2];
        dr[4] <= dr[3];
        dr[5] <= dr[4];
        dr[6] <= dr[5];
        dr[7] <= dr[6];
    end
end

always@(posedge clk)
begin
    case(cnt[20:18])
        3'b000: begin an <= 0; d <= dr[0]; end
        3'b001: begin an <= 1; d <= dr[1]; end
        3'b010: begin an <= 2; d <= dr[2]; end
        3'b011: begin an <= 3; d <= dr[3]; end
        3'b100: begin an <= 4; d <= dr[4]; end
        3'b101: begin an <= 5; d <= dr[5]; end
        3'b110: begin an <= 6; d <= dr[6]; end
        3'b111: begin an <= 7; d <= dr[7]; end
    endcase
end

// ״̬�����ƶ�ȡ��д��
always @(posedge clk) begin
    if (clear) begin
        pspi_we <= 0;
        pspi_rd <= 0;
        write_in_progress <= 0;
        read_in_progress <= 0;
    end else begin
        // ��ȡ��0��ַ���������
        if (!read_in_progress && !write_in_progress && !pspi_we && !pspi_rd) begin
            pspi_a <= 32'd0;  // ��ȡ��0��ַ
            pspi_rd <= 1'b1;  // ������ȡ�ź�
            read_in_progress <= 1'b1; // ��ʼ��ȡ����
        end 
        else if (read_in_progress) begin
            pspi_rd <= 1'b0;
            if (read_in_progress && pspi_ready) begin
                read_in_progress <= 0;
                if (mouse_xy != mouse_data) begin
                    mouse_data <= mouse_xy;
                    write_in_progress <= 1'b1;  // ����д������
                    pspi_a <= mouse_addr;
                    pspi_d <= RED32;
                    pspi_we <= 1'b1;
                end
            end
        end
        else if (write_in_progress) begin
            pspi_we <= 1'b0;
            // д��RED32���ݵ�Ŀ���ַ
            if (write_in_progress && pspi_ready) begin
                write_in_progress <= 1'b0; // д�����
            end
        end
    end
end

pspi_host #(.PSPI_WIDTH(PSPI_WIDTH)) pspi_host_inst (
		.clk(clk),
		.rst(clear),

		.a(pspi_a),
		.d(pspi_d),
		.we(pspi_we),
		.rd(pspi_rd),
		.spo(pspi_spo),
		.ready(pspi_ready),

		.sck(sck),
		.mosi(mosi),
		.miso(miso)
	);

endmodule

