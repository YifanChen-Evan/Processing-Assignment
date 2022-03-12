import rita.*;

import uibooster.*;
import uibooster.components.*;
import uibooster.model.*;
import uibooster.model.formelements.*;
import uibooster.model.options.*;
import uibooster.utils.*;

import java.util.List;
import java.util.ListIterator;
import java.util.Arrays;

import controlP5.*;


PImage moviesImg;
Table movieLines, movieList;

ControlP5 dialogueArea;
Textarea myDialogue;

int dialogueAreaWidth = 670;
int dialogueAreaHeight = 680;
int infoAreaWidth = 300;
int infoAreaHeight = 300;
int resultAreaWidth = 300;
int resultAreaHeight = 300;

float countLines, count_prp, percentage;

String infoText, resultText;


void setup() {
  size(1000, 700);
  moviesImg = loadImage("1000x700-movies.png");
  background(moviesImg);

  // load two datasets
  movieLines = loadTable("movie_lines_header.csv", "header");
  movieList = loadTable("movie_titles_metadata_header.csv", "header");

  // analyze the movieList (movie_titles.csv) and get data
  List<String> movieNames = new ArrayList<>(); // declare a string list for all of movie names
  List<String> movieIDs1 = new ArrayList<>(); // declare a string list for all of movie IDs in movieList
  movieNames = Arrays.asList(movieList.getStringColumn("MovieName")); // get all of movie names and put them into a string list
  movieIDs1 = Arrays.asList(movieList.getStringColumn("MovieID")); // get all of movie IDs and put them into a string list

  // create a selection dialogue for all of movieNames
  String selectionName = new UiBooster().showSelectionDialog(
    "What movie do you want to search?",
    "Search a Movie",
    movieNames);
  println(selectionName); // print the selected movie name

  // get the ID corresponding to the selected movie
  String id = "";
  for (int i = 0; i < movieNames.size(); i++) {
    String name = movieNames.get(i);
    if (selectionName == name) {
      id = movieIDs1.get(i);
      break;
    }
  }
  println(id); //print the selected movie ID

  // analyze the movieLines (movie_lines.csv) and get data
  List<String> RoleNames = new ArrayList<>(); // declare a string list for all of movie characters including duplicate characterNames
  RoleNames = Arrays.asList(movieLines.getStringColumn("CharacterName")); // get all of movie characters and put them into a string list

  List<String> MovieIDs2 = new ArrayList<>(); // declare a string list for all of movie IDs in movieLines including duplicate ID
  MovieIDs2 = Arrays.asList(movieLines.getStringColumn("MovieID")); // get all of movie IDs and put them into a string list

  List<String>   MovieLine = new ArrayList<>();// declare a string list for all of movie dialogues
  MovieLine = Arrays.asList(movieLines.getStringColumn("MovieLine")); // get all of movie dialogues and put them into a string list

  List<String>   myRoleNames = new ArrayList<>(); // declare a string list for characters in selected movie including duplicate characterNames
  List<String>   selectedMovieRoles = new ArrayList<>(); // declare a string list for all of movie characters in selected movie (only characterNames)
  List<String>   myMovieLine = new ArrayList<>(); // declare a string list for all dialogues in selected movie
  List<String>   selectMovieLine = new ArrayList<>(); // declare a string list for dialogues of selected character

  // abstract all characterNames (include duplicate names) and dialogues in selected movie
  for (int i = 0; i < RoleNames.size(); i++) {
    String s = MovieIDs2.get(i);
    if (s.equals(id)) {
      myRoleNames.add(RoleNames.get(i));
      myMovieLine.add(MovieLine.get(i));
      selectedMovieRoles.add(RoleNames.get(i)); // Now, it contains all characterNames in selected movie
    }
  }
  println(myRoleNames.size()); // print the number of lines of dialogues in selected movie

  // remove duplicate characterNames
  for (int i = 0; i < 10; i++) {
    for (int h = 0; h < selectedMovieRoles.size(); h++) {
      String s1 = selectedMovieRoles.get(h);
      for (int k = h+1; k < selectedMovieRoles.size(); k++) {
        String s2 = selectedMovieRoles.get(k);
        if (s1.equals(s2)) {
          selectedMovieRoles.remove(selectedMovieRoles.get(k));
        }
      }
    }
  }

  //println(AllRoleNames);

  // create a selection dialogue for all of characters in selected movie
  String selectRoleNames = new UiBooster().showSelectionDialog(
    "What character do you want to search?",
    selectionName,
    selectedMovieRoles);

  // abstract selected character's dialogues from all dialogues in selected movie
  for (int i = 0; i < myRoleNames.size(); i++) {
    String s = myRoleNames.get(i);
    if (s.equals(selectRoleNames)) {
      selectMovieLine.add(myMovieLine.get(i));
    }
  }
  //println(SelectRoleNames);
  //println(SelectMovieLine);

  // diaplay selected character's dialogues
  String selectedDialogues = "";
  for (int i = 0; i < selectMovieLine.size(); i++) {
    selectedDialogues += selectMovieLine.get(i)+"\n";
  }

  // convert String into String[]
  String[] selectedDialogues_split = selectedDialogues.split("\n");

  // create a text area for dialogues of selected character (http://www.sojamo.de/libraries/controlP5/examples/controllers/ControlP5textarea/ControlP5textarea.pde)
  dialogueArea = new ControlP5(this);
  myDialogue = dialogueArea.addTextarea("txt")
    .setPosition(10, 10)
    .setSize(dialogueAreaWidth, dialogueAreaHeight)
    .setFont(createFont("arial", 20))
    .setLineHeight(40)
    .setColor(color(128))
    .setColorBackground(color(255, 100))
    .setColorForeground(color(255, 100))
    ;

  myDialogue.setText(selectedDialogues);

  // tag the selected dialogues with part of speech tag
  String [] partsOfSpeech = RiTa.pos(selectedDialogues);
  println(partsOfSpeech);

  // count how many lines in selected character's dialogues
  countLines = 0;
  for (int i = 0; i < myRoleNames.size(); i++) {
    String lines = myRoleNames.get(i);
    if (lines.equals(selectRoleNames)) {
       countLines++;
    }
  }
  println("countLines: " + countLines); // print the number of lines of dialogues in selected character

  // count how many lines of dialogues containing a personal pronoun
  count_prp = 0;
  for (String temp : selectedDialogues_split) {
    String[] rita = RiTa.pos(temp);
    boolean flag = false;
    for (String rita_temp : rita) {
      if (rita_temp.contains("prp")) {
        flag = true;
      }
    }
    if (flag == true) {
       count_prp++;
    }
  }
  println("count_prp: " + count_prp); // print the number of lines of dialogues containing a personal pronoun
  
  // calculate the percentage
  percentage = (count_prp / countLines) * 100;
  println(percentage);
}

void changeWidth(int theValue) {
  myDialogue.setWidth(theValue);
}

void changeHeight(int theValue) {
  myDialogue.setHeight(theValue);
}



void draw() {

  // draw a rectangular area to display the instruction or information, 300x300
  fill(255, 255, 255, 5);
  stroke(0);
  rect(10 + dialogueAreaWidth + 10, 10, infoAreaWidth, infoAreaHeight);

  // draw a rectangular area to display the percentage of lines of dialogue containing a personal pronoun, 300x300
  fill(255, 255, 255, 5);
  stroke(0);
  rect(10 + dialogueAreaWidth + 10, 10 + infoAreaHeight +10, resultAreaWidth, resultAreaHeight);

  // declare the text
  infoText = "This is an application that can calculate the the percentage of lines of dialogue containing a personal pronoun";
  resultText = "total lines: " + str(countLines) + "\n" + "lines containing prp: " + str(count_prp) + "\n" + "percentage: " + str(percentage)+ "%";

  // set the position for starting content
  fill(0);
  textAlign(CENTER, CENTER);
  textSize(100);
  textSize(20);
  text(infoText, 10 + dialogueAreaWidth + 10, 10, infoAreaWidth, infoAreaHeight);
  text(resultText, 10 + dialogueAreaWidth + 10, 10 + infoAreaHeight +10, resultAreaWidth, resultAreaHeight);
}
