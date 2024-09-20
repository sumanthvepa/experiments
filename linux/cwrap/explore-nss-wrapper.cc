//--------------------------------------------------------------------
// explore_nss_wrapper.cc: A program reads the contents of the
// password database on Unix like systems.
//
// Copyright (C) 2024 Sumanth Vepa.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <https://www.gnu.org/licenses/>.
//--------------------------------------------------------------------
#include <iostream>
#include <pwd.h>
#include <sys/types.h>

// This program is called by explore-nss-wrapper.sh
// to demonstrate that nss-wrapper can replace the system's
// password database with another one on the fly. 

// When run outside of the nss-wrapper, this program
// will read the machines actuall password file /etc/passwd
// When called inside the wrapper, it will read the custom
// password file that is located in this folder.

auto main() -> int {
  struct passwd *entp = nullptr;
  // This opens the password database
  setpwent();
  // This iterates over each entry in the
  // password database. Returns 0 when
  // there are no more entries to be read
  while ((entp = getpwent()) != nullptr) {
    std::cout << entp->pw_name << ":"
	      << entp->pw_uid << ":"
	      << entp->pw_dir << ":"
	      << entp->pw_shell << "\n";
  }
  // This closes the password database
  endpwent();
}

