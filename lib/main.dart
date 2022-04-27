import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';

/// Main method. Creates and runs main Class Object - RunGame.
void main() {
  var game = RunGame();
  runApp(GameWidget(game: game));
}

/// RunGame Class. This class creates the main variables for the player, loads
/// the assets for the player to see. Also houses the onTap method for the player
/// to tap the screen.
class RunGame extends FlameGame with TapDetector, HasCollisionDetection {

  /// Creates class objects from the 3 other classes
  late Player playerObj; // Player object
  late Enemy enemyObj; // Enemy object
  late Coin coinObj; // Coin object

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
  late bool startGame = false; // Holds bool for when user clicks to start game
  bool delayLogo = true; // Holds bool to trigger delay on Bomb Games logo
  bool loadingLogoShow = true; // Holds bool to trigger onTap when logo hides

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
      ..position = Vector2(screenWidth / 2, -screenHeight / 2)
      ..anchor = Anchor.center;
    //add(gameOver);

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
      ..position = Vector2(screenWidth / 2, screenHeight * .38)
      ..anchor = Anchor.center;

    titleText
      ..sprite = await loadSprite('title_text2.png')
      ..width = screenWidth * .6
      ..height = screenWidth * .35
      ..position = Vector2(screenWidth / 2, screenHeight * .3)
      ..anchor = Anchor.center;


    // Sets scoreText in top right with score 0.
    scoreText
      ..text = "Score: 0"
      ..anchor = Anchor.topRight
      ..x = screenWidth * .97
      ..y = screenHeight * .08;
    scoreTextGame
      ..text = enemyObj.getScore().toString()
      ..anchor = Anchor.center
      ..position = Vector2(screenWidth / 2, screenHeight * .62);
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

    add(instructionText);
    add(playerObj);
    add(titleText);
    add(loadingLogo);
    loadingLogo.onLoad();
  }

  /// Updates the scoreText to current score.
  @override
  Future<void> update(double dt) async {
    super.update(dt);
    if (delayLogo) {
      await Future.delayed(const Duration(seconds: 2), (){
        loadingLogo.position = Vector2(0.0, -screenHeight * 2);
        loadingLogoShow = false;
      });
      delayLogo = false;
    }

    if (startGame && titleText.y > -200) {
      titleText.position.add(Vector2(0 , -400) * dt);
      if (titleText.y <= -200) {
        remove(titleText);
      }
    }




    if (gameOver.isLoaded && gameOver.y < screenHeight / 2) {
      gameOver.position.add(Vector2(0 , 500) * dt);
      print('GOIN THROUGH THISSSSXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX;');
    }
    if (gameOver.y >= screenHeight / 2) {
      gameOver.position.add(Vector2(0 , 0));
      print('WE MADE IT HERE HERE HERE HEREH HERE');
    }

    if (playerObj.getGameLost()) {
      gameLostActions(dt);
      add(gameOver);
      add(gameOverText);

      print('this is the y: ' + gameOver.y.toString());
    } else {
      coinsText
          .text = playerObj.getCoins().toString();
      scoreText
          .text = "Score: " + enemyObj.getScore().toString();
    }
  }

  /// Game lost actions
  void gameLostActions(double dt) {


    scoreTextGame.text = enemyObj.getScore().toString();
    add(scoreTextGame);

    remove(scoreText);
    //coin.position = Vector2(-screenWidth, -screenHeight);
    //scoreText.position = Vector2(-screenWidth, -screenHeight);
    enemyObj.position = Vector2(-screenWidth, -screenHeight);
    coinObj.position = Vector2(-screenWidth, -screenHeight);
  }

  /// Method performs actions when user clicks screen. Reverses velocity of
  /// player object on each click. Checks if first click and adds score to
  /// screen if it is.
  @override
  void onTap() {
    super.onTap();
    if (!loadingLogoShow) {
      if (!startGame) {
        add(scoreText);
        remove(instructionText);
        add(enemyObj);
        add(coinObj);
        add(coin);
        add(coinsText);
        startGame = true;
      }
      velocityPlayer = velocityPlayer * -1.0;
      playerObj.updateVelocity(Vector2(velocityPlayer, 0.0));
    }
    if (playerObj.getGameLost()) {
      gameOver.position = (Vector2(-100, -100));
      gameOverText.position = (Vector2(-100, -100));
      print('SHHHH');
    }
  }
}





/// Coin Class -
class Coin extends SpriteComponent with HasGameRef<FlameGame>, CollisionCallbacks {
  late ShapeHitbox hitbox;
  late Vector2 velocity;
  bool _collision = false;
  late var widthScreen;
  late var heightScreen;

  Coin(Sprite sprite, width, height) {
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
    hitbox.setOpacity(.99);
    if (other is Player) {
      y = - height * 1.2;
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    hitbox.setOpacity(.01);
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
    hitbox.setOpacity(.99);
    // if (other is ScreenHitbox) {
    //   print('other is sprite component');
    //   //removeFromParent();
    //   velocity = Vector2(0.0, 0.0);
    //   return;
    // }
    if (other is Enemy) {
      gameLost = true;
      removeFromParent();
    }
  }

  /// Performs actions on end of collision with player object
  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    hitbox.setOpacity(.01);
    if (other is Coin) {
      coins++;
      print('OTHER IS COIN POG COIN');
    }
  }
}





/// Enemy Class -
class Enemy extends SpriteComponent with HasGameRef<FlameGame>, CollisionCallbacks {
  late ShapeHitbox hitbox;
  late Vector2 velocity;
  bool _collision = false;
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

  @override
  void onCollisionStart(
      Set<Vector2> intersectionPoints,
      PositionComponent other,
      ) {
    super.onCollisionStart(intersectionPoints, other);
    hitbox.setOpacity(.99);
    if (other is ScreenHitbox) {
      //removeFromParent();
      //velocity = Vector2(0, 0);
      return;
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);
    hitbox.setOpacity(.01);
  }
}