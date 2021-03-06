extern crate rpassword;
use hyper::StatusCode;
use structopt::StructOpt;
use std::thread;
use webbrowser::{self, BrowserOptions};
use home::home_dir;
use std::path::{PathBuf};
use std::fs;
use std::fs::File;
use std::io::{self, Write};
use std::process::{Command};


#[derive(StructOpt, Debug)]
#[structopt(about = "run scripts from scriptz.sh")]
struct Cli {
  #[structopt(subcommand)]
  cmd: Option<Cmd>
}

#[derive(StructOpt, Debug)]
enum Cmd {
  Show {
    #[structopt(required = true)]
    file: String,
  },
  Run {
    #[structopt(required = true)]
    file: String,
  },
  Login {
    #[structopt(default_value = "", short = "t", long="token")]
    token: String
  },
  Logout {},
  Ls {},
}

fn is_sh(str: String) -> bool {
  str.ends_with(".sh")
}

fn get_token_file() -> PathBuf {
  home_dir().unwrap().join(".scriptz").join("token")
}
#[cfg(debug_assertions)]
fn get_origin() -> String {
  return String::from("https://scriptz.sh")
}

#[cfg(not(debug_assertions))]
fn get_origin() -> String {
  return String::from("https://scriptz.sh")
}

async fn send_get(endpoint: String, token: Option<String>) -> String {
  let client = reqwest::Client::new();
  let url = format!("{}{}", get_origin(), endpoint);
  // panic!();
  let mut req = client
    .get(&url);
  if token.is_some() {
    req = req
    .header("Authorization", format!("Bearer {}", token.unwrap()))
  }
  let res = req
    .send()
    .await.unwrap();

  let status = res.status();
  let text = res.text().await.unwrap();
  if status != StatusCode::OK {
    panic!(text)
  }
  text
}

fn get_token() -> String {
  fs::read_to_string(get_token_file()).unwrap_or(String::from(""))
}
async fn get_file(filename: String) -> String {
  send_get(format!("/d/{}", filename), Some(get_token())).await
}

async fn make_temp_file(filename: String, file_contents: String)
  -> Result<PathBuf, io::Error> {
  let dir = std::env::temp_dir();
  let file_path = dir.join(str::replace(filename.clone().as_str(), "/", "_"));
  let str_path = file_path.clone().as_path().display().to_string();
  fs::create_dir(dir).ok();
  let mut new_file = File::create(str_path)?;
  new_file.write_all(file_contents.as_bytes())
    .expect("Couldn't write to file");
  Ok(file_path)
}


async fn run_script(filename: String) {
  let file_contents = get_file(filename.clone()).await;
  let temp_file = make_temp_file(filename.clone(), file_contents.clone()).await
    .expect("Couldn't make temporary file.");
  let child = Command::new("bash")
    .arg(temp_file.as_path().display().to_string())
    .spawn()
    .expect("The script failed.");
  child.wait_with_output()
    .expect("There was an error running the file.");
}

async fn list() {
  let ls = send_get("/api/cli/script-names".to_string(), Some(get_token())).await;
  println!("{}", ls)
}

async fn show_script(file: String) {
  let file = get_file(file).await;
  println!("{}", file);
}

fn login(mut token: String) {
  let token_url = get_origin() + "/cli/token";
  // Larry: is there a better way to do this?
  let token_url_2 = token_url.clone();
  if token == "" {
    thread::spawn(move || {
      webbrowser::open_browser_with_options(
        BrowserOptions {
          url: String::from(token_url),
          suppress_output: Some(true),
          browser: Some(webbrowser::Browser::Default),
        }
      )
    });
    println!("Please copy the token from the browser, paste it in the terminal, and press enter.");
    println!("");
    println!("{}", token_url_2);
    println!("");
    token = rpassword::read_password_from_tty(Some("Token (Hidden): ")).unwrap();
  }
  let scriptz_dir = home_dir().unwrap().join(".scriptz");
  std::fs::create_dir_all(scriptz_dir.clone())
    .expect("Couldn't create .scriptz dir");
  std::fs::write(scriptz_dir.join("token").clone(), token)
    .expect("Couldn't write token to scriptz dir");
}

#[tokio::main]
async fn main() -> Result<(), ()> {
  let first_arg = std::env::args().nth(1).clone()
    .expect("You must type a command. Type --help for usage.");
  let cmd: Cmd;
  if is_sh(first_arg.clone()) {
    cmd = Cmd::Run {
      file: first_arg.clone()
    }
  } else {
    let args = Cli::from_args();
    cmd = args.cmd.unwrap();
  }
  match cmd {
    Cmd::Run{ file } => {
      run_script(file).await;
      Ok(())
    },
    Cmd::Show{ file } => {
      show_script(file).await;
      Ok(())
    },
    Cmd::Login{ token } => {
      login(token);
      Ok(())
    },
    Cmd::Logout{} => {
      std::fs::remove_file(get_token_file())
        .expect("Couldn't delete token file.");
      Ok(())
    },
    Cmd::Ls{} => {
      list().await;
      Ok(())
    },
  }
}