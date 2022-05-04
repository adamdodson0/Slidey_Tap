import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

/// Main method. Creates and runs main Class Object - RunGame.
void main() {
  var game = RunGame();
  runApp(GameWidget(game: game));
  Flame.device.setPortrait();
}

/// RunGame Class. This class creates the main variables for the player, loads
/// the assets for the player to see. Also houses the onTap method for the player
/// to tap the screen.
class RunGame extends FlameGame with HasCollisionDetection, HasTappables {

  /// Creates class objects from the 3 other classes
  late Player playerObj; // Player object
  late Enemy enemyObj; // Enemy object
  late Coin coinObj; // Coin object

  late ScreenTappable buttonObj; // ScreenTappable object
  late LeftButton leftObj;
  late RightButton rightObj;
  late HomeButton homeObj;
  late RetryButton retryObj;

  /// Creates text and image components
  /// Main game screen
  SpriteComponent loadingLogo = SpriteComponent(); // Holds bomb games logo
  SpriteComponent titleText = SpriteComponent(); // Holds main title text when game starts
  TextComponent instructionText = TextComponent(); // Holds instruction text when game starts
  TextComponent scoreText = TextComponent(); // Holds score in top right
  TextComponent coinsText = TextComponent(); // Holds coin amount in top left
  SpriteComponent coin = SpriteComponent(); // Holds coin image in top left
  /// Game over screen
  SpriteComponent gameOver = SpriteComponent(); // Holds game over box on game over screen
  SpriteComponent gameOverText = SpriteComponent(); // Holds game over text on game over screen
  TextComponent scoreTextGame = TextComponent(); // Holds score in game over screen
  /// Creates variables to help setup / run the game
  late final screenWidth; // Holds screen width
  late final screenHeight; // Holds screen Height
  var velocityPlayer; // Holds players velocity, changes each click
  /// Variables to help determine which section of the game the user is at
  late bool startGame = false; // Holds bool for when user clicks to start game
  bool gameLoading = true; // helps updater
  bool duringGame = false;
  bool gameOverHelper = true;
  bool firstMenu = false;
  bool animationWait = false;

  // Used to hold number of clicks on main button
  var clicks = 0;
  var leftClick = 0;
  var rightClick = 0;
  var homeClick = 0;
  var retryClick = 0;

  /// Performs all the actions after everything loads. sets objects
  /// and adds them.
  @override
  Future<void> onLoad() async {
    super.onLoad();
    // Sets screen variables to correct sizes
    screenWidth = size[0];
    screenHeight = size[1];
    // Sets velocity to the screenWidth
    velocityPlayer = screenWidth;
    // Creates player object and adds it to screen
    playerObj = Player(await loadSprite('ball.png'), screenWidth, screenHeight);
    // Creates enemy object and adds it to screen
    enemyObj = Enemy(await loadSprite('ball.png'), screenWidth, screenHeight);
    // Creates coin object and adds it to the screen
    coinObj = Coin(await loadSprite('coin.png'), screenWidth, screenHeight);

    // Creates button object, will be added to screen later
    buttonObj = ScreenTappable(await loadSprite('tappable_1.png'), screenWidth, screenHeight);
    leftObj = LeftButton(await loadSprite('leftButton.png'), screenWidth, screenHeight);
    rightObj = RightButton(await loadSprite('rightButton.png'), screenWidth, screenHeight);
    homeObj = HomeButton(await loadSprite('home_button.png'), screenWidth, screenHeight);
    retryObj = RetryButton(await loadSprite('retry.png'), screenWidth, screenHeight);

    /// Creates and sets attributes to sprite components (images and texts)
    // Adds background to screen
    add(SpriteComponent()
      ..sprite = await loadSprite('bg.jpg')
      ..size = size
    );
    loadingLogo
      ..sprite = await loadSprite('logo.jpg')
      ..width = screenWidth * 2
      ..height = screenWidth * 2.1
      ..position = Vector2(screenWidth / 2, screenHeight / 2)
      ..anchor = Anchor.center;
    gameOver
      ..sprite = await loadSprite('game_over.png')
      ..width = screenWidth * .8
      ..height = screenWidth * .8
      ..position = Vector2(screenWidth / 2,  screenHeight * 2)
      ..anchor = Anchor.topCenter;
    coin
      ..sprite = await loadSprite('coin.png')
      ..width = screenWidth * .09
      ..height = screenWidth * .09
      ..position = Vector2(screenWidth * .05, screenHeight * .09)
      ..anchor = Anchor.center;
    gameOverText
      ..sprite = await loadSprite('game_over_text.png')
      ..width = screenWidth * .7
      ..height = screenWidth * .2
      ..position = Vector2(screenWidth / 2, -screenHeight / 2)
      ..anchor = Anchor.center;
    titleText
      ..sprite = await loadSprite('title_text2.png')
      ..width = screenWidth * .6
      ..height = screenWidth * .35
      ..position = Vector2(screenWidth / 2, screenHeight * .3)
      ..anchor = Anchor.center;
    scoreText
      ..text = "Score: 0"
      ..anchor = Anchor.topRight
      ..x = screenWidth * .97
      ..y = screenHeight * .08;
    scoreTextGame
      ..text = enemyObj.getScore().toString()
      ..anchor = Anchor.center
      ..position = Vector2(screenWidth / 2, screenHeight * .55);
    instructionText
      ..text = "Click anywhere to begin"
      ..anchor = Anchor.center
      ..x = screenWidth / 2
      ..y = screenHeight / 2;
    coinsText
      ..text = "0"
      ..anchor = Anchor.topLeft
      ..x = screenWidth * .11
      ..y = screenHeight * .073;

    // Adds components to screen onLoad after creation.
    add(instructionText);
    add(playerObj);
    add(titleText);
    add(loadingLogo);
  }

  /// Updates the scoreText to current score.
  @override
  Future<void> update(double dt) async {
    super.update(dt);
    // Performs nothing if game is loading, logo is showing
    if (!gameLoading) {
      // Updates game when at main menu screen
      if (firstMenu) {
        firstMenuUpdater();
      } // Updates game when user is at game over
      else if (playerObj.getGameLost()) {
        gameOverUpdater(dt);
      } // Updates game when user is playing main game
      else if (duringGame) {
        duringGameUpdater(dt);
      }


      if (clicks != buttonObj.getTapScreen()) {
        if (leftClick != leftObj.getTapScreen()) {
          print('left click performed');
          leftClick = leftObj.getTapScreen();
        } else if (rightClick != rightObj.getTapScreen()) {
          print('right click performed');
          rightClick = rightObj.getTapScreen();
        } else if (homeClick != homeObj.getTapScreen()) {
          print('home click performed');
        } else if (retryClick != retryObj.getTapScreen()) {
          print('retry click performed');
          onTap();
        } else {
          onTap();
        }
        clicks = buttonObj.getTapScreen();
      }



    } else { // Perform delay to hide loading logo, and set gameLoading to false
      await Future.delayed(const Duration(seconds: 2), (){
        loadingLogo.position = Vector2(0.0, -screenHeight * 2);
        // Adds main tappable button
        if (!buttonObj.isMounted) {
          add(buttonObj);
          add(leftObj);
          add(rightObj);
        }
        gameLoading = false;
      });
    }
  }

  void firstMenuUpdater() {

  }

  void gameOverUpdater(double dt) {
    // Only performs this once each time a game over occurs
    if (gameOverHelper) {
      if (titleText.y > -200) {
        remove(titleText);
      }
      duringGame = false;
      add(gameOver);
      gameOver.position = Vector2(screenWidth / 2, screenHeight * 1.6);
      add(gameOverText);
      gameOverText.position = Vector2(screenWidth / 2, -screenHeight / 2);
      remove(scoreText);
      coinObj.position = Vector2(-screenWidth, -screenHeight);
      gameOverHelper = false;
      // Makes onTap not perform any function until done animating
      animationWait = true;
    }
    if (gameOver.isLoaded && gameOver.y > screenHeight / 4.3) {
      gameOver.position.add(Vector2(0 , -500) * dt);
    } else if (gameOver.isLoaded && gameOver.y <= screenHeight / 4.3) {
      gameOver.position.add(Vector2(0 , 0));

      scoreTextGame.text = enemyObj.getScore().toString();
      if (!scoreTextGame.isLoaded) {
        add(scoreTextGame);
        add(homeObj);
        add(retryObj);
      }
      // Make onTap perform action again
      animationWait = false;

    }
    if (gameOverText.isLoaded && gameOverText.y < (screenHeight / 2) - (screenWidth * .41)) {
      gameOverText.position.add(Vector2(0 , 650) * dt);
    } else if (gameOverText.isLoaded && gameOverText.y >= (screenHeight / 2) - (screenWidth * .41)) {
      gameOverText.position.add(Vector2(0 , 0));
    }
  }

  void duringGameUpdater(double dt) {
    if (startGame && titleText.y > -200) {
      titleText.position.add(Vector2(0 , -400) * dt);
      if (titleText.y <= -200) {
        remove(titleText);
      }
    }
    coinsText.text = playerObj.getCoins().toString();
    scoreText.text = "Score: " + enemyObj.getScore().toString();
  }

  /// Method performs actions when user clicks screen. Reverses velocity of
  /// player object on each click. Checks if first click and adds score to
  /// screen if it is.
  @override
  void onTap() {
    //super.onTap();
    // Nothing performed if Logo is showing on screen
    if (!gameLoading && !animationWait) {
      // If game is just being started add sprite components
      if (!startGame) {
        startGameTap();
      } // When user taps screen after they lost the game
      else if (playerObj.getGameLost()) {
        gameLostTap();
      } // Game is playing, user taps cause player to go back and forth
      else {
        velocityPlayer = velocityPlayer * -1.0;
        playerObj.updateVelocity(Vector2(velocityPlayer, 0.0));
      }
    }
  }

  void startGameTap() {
    add(scoreText);
    remove(instructionText);
    add(enemyObj);
    add(coinObj);
    add(coin);
    add(coinsText);
    remove(leftObj);
    remove(rightObj);
    startGame = true;
    velocityPlayer = velocityPlayer * -1.0;
    playerObj.updateVelocity(Vector2(velocityPlayer, 0.0));
    duringGame = true;
  }

  void gameLostTap() {
    remove(gameOver);
    remove(gameOverText);
    remove(scoreTextGame);
    //gameOverText.position = (Vector2(0, -screenHeight * 2));
    add(enemyObj);
    add(scoreText);
    remove(homeObj);
    remove(retryObj);

    enemyObj.setScore(0);

    enemyObj.position = Vector2(screenWidth / 2, - screenWidth / 5);
    coinObj.position = Vector2(screenWidth / 2, -screenWidth / 5);
    add(playerObj);
    playerObj.setGameLost(false);
    duringGame = true;
    gameOverHelper = true;
    //gameOver.position = (Vector2(0, -screenHeight * 2));
    //enemyObj.position = Vector2(-screenWidth, -screenHeight);
  }
}






class ScreenTappable extends SpriteComponent with Tappable {

  late var widthScreen;
  late var heightScreen;
  var tapScreen = 0;

  ScreenTappable(Sprite sprite, width, height) {
    widthScreen = width;
    heightScreen = height;
    this.sprite = sprite;
    size = Vector2(widthScreen, heightScreen);
    anchor = Anchor.center;
    position = Vector2(widthScreen / 2, heightScreen / 2);
  }

  @override
  bool onTapDown(TapDownInfo info) {
    tapScreen++;
    return true;
  }

  int getTapScreen() {
    return tapScreen;
  }
}


class LeftButton extends SpriteComponent with Tappable {

  late var widthScreen;
  late var heightScreen;
  var tapScreen = 0;

  LeftButton(Sprite sprite, width, height) {
    widthScreen = width;
    heightScreen = height;
    this.sprite = sprite;
    size = Vector2(widthScreen / 6, widthScreen / 6);
    anchor = Anchor.center;
    position = Vector2(widthScreen * .25, heightScreen * .81);
  }

  @override
  bool onTapDown(TapDownInfo info) {
    tapScreen++;
    return true;
  }

  int getTapScreen() {
    return tapScreen;
  }
}

class RightButton extends SpriteComponent with Tappable {

  late var widthScreen;
  late var heightScreen;
  var tapScreen = 0;

  RightButton(Sprite sprite, width, height) {
    widthScreen = width;
    heightScreen = height;
    this.sprite = sprite;
    size = Vector2(widthScreen / 6, widthScreen / 6);
    anchor = Anchor.center;
    position = Vector2(widthScreen * .75, heightScreen * .81);
  }

  @override
  bool onTapDown(TapDownInfo info) {
    tapScreen++;
    return true;
  }

  int getTapScreen() {
    return tapScreen;
  }
}


class HomeButton extends SpriteComponent with Tappable {

  late var widthScreen;
  late var heightScreen;
  var tapScreen = 0;

  HomeButton(Sprite sprite, width, height) {
    widthScreen = width;
    heightScreen = height;
    this.sprite = sprite;
    size = Vector2(widthScreen / 3.5, widthScreen / 3.5);
    anchor = Anchor.center;
    position = Vector2(widthScreen * .68, heightScreen * .8);
  }

  @override
  bool onTapDown(TapDownInfo info) {
    tapScreen++;
    return true;
  }

  int getTapScreen() {
    return tapScreen;
  }
}



class RetryButton extends SpriteComponent with Tappable {

  late var widthScreen;
  late var heightScreen;
  var tapScreen = 0;

  RetryButton(Sprite sprite, width, height) {
    widthScreen = width;
    heightScreen = height;
    this.sprite = sprite;
    size = Vector2(widthScreen / 3.5, widthScreen / 3.5);
    anchor = Anchor.center;
    position = Vector2(widthScreen * .32, heightScreen * .8);
  }

  @override
  bool onTapDown(TapDownInfo info) {
    tapScreen++;
    return true;
  }

  int getTapScreen() {
    return tapScreen;
  }
}








/// Coin Class -
class Coin extends SpriteComponent with HasGameRef<FlameGame>, CollisionCallbacks {
  late ShapeHitbox hitbox;
  late Vector2 velocity;
  late var widthScreen;
  late var heightScreen;

  Coin(Sprite sprite, width, height) {
    widthScreen = width;
    heightScreen = height;
    this.sprite = sprite;
    size = Vector2(widthScreen / 7, widthScreen / 7);
    anchor = Anchor.center;
    position = Vector2(widthScreen / 2, - widthScreen / 5);
    hitbox = CircleHitbox()
      ..setOpacity(.01)
      ..renderShape = true;
    add(hitbox);
    velocity = Vector2(0.0, heightScreen * 1.2);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.add(velocity * dt * .5);
    if (y >= heightScreen * 1.2) {
      y = - height * 1.2;
    }
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints,
      PositionComponent other,
      ) {
    super.onCollisionStart(intersectionPoints, other);
    //hitbox.setOpacity(.99);
    if (other is Player) {
      y = - height * 1.2;
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    //hitbox.setOpacity(.01);
  }
}






/// Player Class -
class Player extends SpriteComponent with HasGameRef<FlameGame>, CollisionCallbacks {
  late ShapeHitbox hitbox; // Holds hitbox of player
  late Vector2 velocity; // Holds velocity of player
  bool lockVelocity= true; // Bool to check when to lock velocity of player
  late var widthScreen; // Holds screen width
  late var heightScreen; // Holds screen height
  var coins = 0; // Holds coins of user
  bool gameLost = false;

  /// Creates Player object, sets width, height, size, position,
  /// sets hitbox, and adds hitbox and velocity
  Player(Sprite sprite, width, height) {
    this.sprite = sprite;
    // Sets width and height variables to screen width and height
    widthScreen = width;
    heightScreen = height;
    // Sets size to one fifth of the screen width
    size = Vector2(widthScreen / 5, widthScreen / 5);
    anchor = Anchor.center;
    // Sets position in middle of screen and 8 / 10ths down the screen
    position = Vector2(widthScreen / 2, heightScreen * .8);
    hitbox = CircleHitbox()
      ..setOpacity(.01)
      ..renderShape = true;
    add(hitbox);
    velocity = Vector2(0.0, 0.0);
  }

  /// Returns current coins for user to update coinsText
  getCoins() {
    return coins;
  }

  /// Sets the gameLost bool
  setGameLost(bool setLost) {
    gameLost = setLost;
  }

  getGameLost() {
    return gameLost;
  }

  ///
  @override
  void update(double dt) {
    super.update(dt);
    if (x <= width * .7 && lockVelocity== true || x >= (widthScreen - width * .7) && lockVelocity== true) {
      velocity = Vector2(0.0, 0.0);
      lockVelocity= false;
    } else if (x > width * .7 && x < (widthScreen - width * .7)) {
      lockVelocity= true;
    }
    // Updates velocity to move player back and forth
    position.add(velocity * dt * 1.5);
  }

  /// Updates the velocity of the player every time user taps
  /// Multiplies velocity by -1.
  void updateVelocity(velocityInput) {
    velocity = velocityInput;
  }

  /// Performs actions on collisions with player object.
  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other,) {
    super.onCollisionStart(intersectionPoints, other);
    //hitbox.setOpacity(.99);
    if (other is Enemy) {
      gameLost = true;
      removeFromParent();
    }
  }

  /// Performs actions on end of collision with player object
  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    //hitbox.setOpacity(.01);
    if (other is Coin) {
      coins++;
    }
  }
}





/// Enemy Class -
class Enemy extends SpriteComponent with HasGameRef<FlameGame>, CollisionCallbacks {
  late ShapeHitbox hitbox;
  late Vector2 velocity;
  late var widthScreen;
  late var heightScreen;
  var score = 0; // Holds score of user

  Enemy(Sprite sprite, width, height) {
    widthScreen = width;
    heightScreen = height;
    this.sprite = sprite;
    size = Vector2(widthScreen / 5, widthScreen / 5);
    anchor = Anchor.center;
    position = Vector2(widthScreen / 2, - widthScreen / 5);
    hitbox = CircleHitbox()
      ..setOpacity(.01)
      ..renderShape = true;
    add(hitbox);
    velocity = Vector2(0.0, heightScreen * 1.2);
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.add(velocity * dt);
    if (y >= heightScreen * 1.2) {
      y = - height * 1.2;
      score++;
    }
  }

  /// Returns current score for user to update scoreText
  getScore() {
    return score;
  }

  /// Sets score to newScore to update for new game
  setScore(var newScore) {
    score = newScore;
  }

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints,
      PositionComponent other,
      ) {
    super.onCollisionStart(intersectionPoints, other);
    //hitbox.setOpacity(.99);
    if (other is ScreenHitbox) {
      //removeFromParent();
      //velocity = Vector2(0, 0);
      return;
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    //hitbox.setOpacity(.01);
    if (other is Player) {
      removeFromParent();
    }
  }
}