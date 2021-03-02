#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <unistd.h>

// coordinates are given in row major format
// (col,row) = (x,y)

#define R(mul,shift,x,y) \
  _=x; \
  x -= mul*y>>shift; \
  y += mul*_>>shift; \
  _ = 3145728-x*x-y*y>>11; \
  x = x*_>>10; \
  y = y*_>>10;

int8_t b[1761], z[1761];


const int BG_COLOR = 0x00;  // light blue (0/7 red, 3/7 green, 3/3 blue)
volatile int * const VG_ADDR = (int *)0x11100000;
volatile int * const VG_COLOR = (int *)0x11140000;

static void draw_horizontal_line(int X, int Y, int toX, int color);
static void draw_vertical_line(int X, int Y, int toY, int color);
static void draw_background();
static void draw_dot(int X, int Y, int color);
static void draw_donut(int8_t b[1761]);
void wait(int seconds);

void main() {
  int sA=1024,cA=0,sB=1024,cB=0,_;
  for (;;) {  	  	
    memset(b, 32, 1760);  // text buffer
    memset(z, 127, 1760);   // z buffer
    int sj=0, cj=1024;
    for (int j = 0; j < 90; j++) {
      int si = 0, ci = 1024;  // sine and cosine of angle i
      for (int i = 0; i < 324; i++) {
        int R1 = 1, R2 = 2048, K2 = 5120*1024;
        int x0 = R1*cj + R2,
            x1 = ci*x0 >> 10,
            x2 = cA*sj >> 10,
            x3 = si*x0 >> 10,
            x4 = R1*x2 - (sA*x3 >> 10),
            x5 = sA*sj >> 10,
            x6 = K2 + R1*1024*x5 + cA*x3,
            x7 = cj*si >> 10,
            x = 40 + 30*(cB*x1 - sB*x4)/x6,
            y = 12 + 15*(cB*x4 + sB*x1)/x6,
            N = (-cA*x7 - cB*((-sA*x7>>10) + x2) - ci*(cj*sB >> 10) >> 10) - x5 >> 7;

        int o = x + 80 * y;
        int8_t zz = (x6-K2)>>15;
        if (22 > y && y > 0 && x > 0 && 80 > x && zz < z[o]) {
          z[o] = zz;          
          b[o] = N;//".,-~:;=!*#$@"[N > 0 ? N : 0];               	  
        }
        R(5, 8, ci, si)  // rotate i
      }
      R(9, 7, cj, sj)  // rotate j
    }
    draw_background();
    draw_donut(b);
    R(5, 7, cA, sA);
    R(5, 8, cB, sB);   
  }
}

void wait( int seconds )
{   // this function needs to be finetuned for the specific microprocessor
    int i, j, k;
    int wait_loop0 = 100;
    int wait_loop1 = 600;
    for(i = 0; i < seconds; i++)
    {
        for(j = 0; j < wait_loop0; j++)
        {
            for(k = 0; k < wait_loop1; k++)
            {   // waste function, volatile makes sure it is not being optimized out by compiler
                int volatile t = 120 * j * i + k;
                t = t + 5;
            }
        }
    }
}

static void draw_donut(int8_t b[1761]){
	for (int k = 0; 1761 > k; k++){
		if(b[k] >= 0 && b[k] <=11){
			draw_dot(k%80, k/40, b[k]*12);
			draw_dot(k%80, (k/40)+1, b[k]*12);
		}
		else{
			draw_dot(k%80, k/40, 0x00);
			draw_dot(k%80, (k/40)+1, 0x00);
		}
	}     
}


static void draw_horizontal_line(int X, int Y, int toX, int color) {
	toX++;
	for (; X != toX; X++) {
		draw_dot(X, Y, color);
	}
}


static void draw_vertical_line(int X, int Y, int toY, int color) {
	toY++;
	for (; Y != toY; Y++) {
		draw_dot(X, Y, color);
	}
}

// fills the screen with BG_COLOR
static void draw_background() {
	for (int Y = 0; Y != 60; Y++) {
		draw_horizontal_line(0, Y, 79, BG_COLOR);
	}
}

// draws a small square (a single memory cell)
static void draw_dot(int X, int Y, int color) {
	*VG_ADDR = (Y << 7) | X;  // store into the address IO register
	*VG_COLOR = color;  // store into the color IO register, which triggers
	                    // the actual write to the framebuffer at the address
	                    // previously stored in the address IO register
}
