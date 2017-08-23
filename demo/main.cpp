/* -------------------------------------------------------------------------
//	FileName		:	D:\yx_code\yxlua\demo\main.cpp
//	Creator			:	(zc) <zcnet4@gmail.com>
//	CreateTime	:	2017-8-23 17:57
//	Description	:	
//
// -----------------------------------------------------------------------*/
#include "main.h"

// -------------------------------------------------------------------------

#include <chrono>
#include <thread>
#include <signal.h>
#include <thread>
#include <chrono>
//#include "../../vld/src/vld.h"
#include "lua.hpp"
// -------------------------------------------------------------------------
void test_lua();

//////////////////////////////////////////////////////////////////////////
// main
int main(int argc, const char * argv[]) {
  printf("hello android..\n");
  test_lua();
  return 0;
}

extern "C" {
  int luaopen_lsocket(lua_State *L);
}

int script_error_handler(lua_State *L)
{
  lua_getglobal(L, "debug");
  if (!lua_istable(L, -1)) {
    lua_pop(L, 1);
    return 1;
  }
  lua_getfield(L, -1, "traceback");
  if (!lua_isfunction(L, -1)) {
    lua_pop(L, 2);
    return 1;
  }
  lua_pushvalue(L, 1);
  lua_pushinteger(L, 2);
  lua_call(L, 2, 1);
  return 1;
}

void PrintError(lua_State* L)
{
  const char* szMsg(lua_tostring(L, -1));
  if (szMsg == nullptr)
    szMsg = "CLuaManager::PrintError() - (error with no message)";
  lua_pop(L, 1);

  printf(szMsg);
}

int err_handler = 0;
void lua_init(lua_State* L) {

  // Add and save an error handler
  lua_pushcfunction(L, script_error_handler);
  err_handler = lua_gettop(L);

  // 加载lsocket模块与配置require目录。by ZC.
  static char lua_script[] = "package.loaded['lsocket'] = select(1, ...)"
    " package.path = package.path..string.format(\";%s/?.lua\", \"D:\\\\yx_code\")";
  // func
  luaL_loadstring(L, lua_script);
  // arg1
  luaopen_lsocket(L);
  //
  int err = lua_pcall(L, 1, 0, err_handler);
  if (err) {
    PrintError(L);
  }
}

void lua_enable_debug(lua_State* L) {
  int err = luaL_loadstring(L, "require('debug/mobdebug').start()");
  if (err) {
    PrintError(L);
    return;
  }
  err = lua_pcall(L, 0, LUA_MULTRET, err_handler);
  if (err) {
    PrintError(L);
  }
}

void test_lua() {
  lua_State* L = lua_open();
  luaL_openlibs(L);
  //
  lua_init(L);
  lua_enable_debug(L);


  luaL_loadfile(L, "t.lua");

  int err = lua_pcall(L, 0, LUA_MULTRET, err_handler);
  if (err) {
    PrintError(L);
  }

  while (true) {
    std::this_thread::sleep_for(std::chrono::milliseconds(1000));
  }
}

// -------------------------------------------------------------------------
