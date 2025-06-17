#!/bin/bash

function copy_file() {
  local src dst
  src="$1"
  dst="$2"
  if [[ ! -f "$dst" ]]; then
    if [[ -f "$src" ]]; then
      cp "$src" "$dst"
    else
      echo "Source file $src does not exist."
      return 1
    fi
  fi
}

function create_web_boilerplate() {
  local boilerplate_dir=node_modules/html5-boilerplate/dist
  if [[ ! -d "$boilerplate_dir" ]]; then
    echo "Boilerplate directory $boilerplate_dir does not exist."
    return 1
  fi
  # See this stack overflow post for why we don't want to assign
  # the output of `pwd` to the variable directly at the point of declaration:
  # The reason is that the local command always evaluates to 0. Any
  # error in the $(pwd) command will be lost. If you declare and set
  # separately,
  local dest_dir
  dest_dir=$(pwd)

  copy_file "$boilerplate_dir"/index.html "$dest_dir"/index.html
  copy_file "$boilerplate_dir"/404.html "$dest_dir"/404.html
  copy_file "$boilerplate_dir"/icon.png "$dest_dir"/icon.png
  copy_file "$boilerplate_dir"/icon.svg "$dest_dir"/icon.svg
  copy_file "$boilerplate_dir"/favicon.ico "$dest_dir"/favicon.ico
  copy_file "$boilerplate_dir"/robots.txt "$dest_dir"/robots.txt
  copy_file "$boilerplate_dir"/site.webmanifest "$dest_dir"/site.webmanifest
  mkdir -p "$dest_dir"/css
  copy_file "$boilerplate_dir"/css/style.css "$dest_dir"/css/style.css
  mkdir -p "$dest_dir"/img
  touch "$dest_dir"/img/.gitignore
  mkdir -p "$dest_dir"/js
  copy_file "$boilerplate_dir"/js/app.js "$dest_dir"/js/app.js
  mkdir -p "$dest_dir"/js/vendor
  touch "$dest_dir"/js/vendor/.gitignore
  ln -snf icon.png apple-touch-icon.png
  ln -snf icon.png apple-touch-icon-precomposed.png
}

create_web_boilerplate
