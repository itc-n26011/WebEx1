// 1. Database containing 7 scenes 
const scenes = {
  'start': {
    bg: 'images/scene-start.png',
    text: '深夜十一時。雨が窓を打つ音だけが、屋敷に響いていた。\n古い洋館「月見荘」の書斎で、主人の黒沢忠雄が倒れているのが発見された。\n死因は毒殺と思われる。部屋は内側から鍵がかかっており、いわゆる「密室」だった。\nあなたは呼ばれた私立探偵。たった今、現場に到着したところだ。',
    choices: [
      { text: '遺体と書斎の様子を調べる', next: 'examine_desk' },
      { text: '第一発見者である執事に話を聞く', next: 'talk_butler' }
    ]
  },
  'examine_desk': {
    bg: 'images/scene-examine-desk.png',
    text: 'デスクの上には半分飲まれた紅茶のカップ。微かにアーモンドの匂いがする。\n足元には小さな鉄の歯車が落ちており、ノートには「今夜11時、時計台の仕掛けが完成する」と書かれている。',
    choices: [
      { text: '部屋にある大きな古時計を調べる', next: 'examine_clock' },
      { text: '執事に話を聞く', next: 'talk_butler' }
    ]
  },
  'talk_butler': {
    bg: 'images/scene-talk-butler.png',
    text: '執事の田中が語る。「11時に紅茶をお持ちしたところ鍵がかかっており、予備の鍵を使おうとしましたが、内側に鍵が刺さったままで回りませんでした。11時ちょうどに中から『ガチャン』と重い音がしました」',
    choices: [
      { text: '部屋にある大きな古時計を調べる', next: 'examine_clock' },
      { text: '遺体と書斎の様子を調べる', next: 'examine_desk' }
    ]
  },
  'examine_clock': {
    bg: 'images/scene-examine-clock.png',
    text: '古時計の裏を開けると、歯車が一つ欠けており、糸がドアの鍵穴まで伸びていた跡があった！\n11時になると自動で内側から鍵を閉める仕掛けだ！',
    choices: [
      { text: '全員を集めて推理を披露する', next: 'confrontation' }
    ]
  },
  'confrontation': {
    bg: 'images/scene-ending-confrontation.png',
    text: '関係者が集まった。あなたはすべての手がかりを整理し、犯人を指名する時が来た。',
    choices: [
      { text: '【推理発表】執事田中が古時計のカラクリを使って鍵を閉めた！', next: 'good_end' },
      { text: '【推理発表】被害者自身が自殺し、執事をハメるために鍵を閉めた！', next: 'bad_end' }
    ]
  },
  'good_end': {
    bg: 'images/ending-good.png',
    text: '「犯人はあなただ、田中さん！」\nあなたが歯車と糸の跡を突きつけると、執事は膝から崩れ落ちた。\n\n【HAPPY END - 密室解明】',
    choices: [
      { text: '最初からやり直す', next: 'start' }
    ]
  },
  'bad_end': {
    bg: 'images/ending-bad.png',
    text: '「被害者の自殺です！」と主張したが、無理のある推理に警察もあきれ顔だ。\n真犯人は闇の中に消えてしまった……。\n\n【BAD END - 迷宮入り】',
    choices: [
      { text: '最初からやり直す', next: 'start' }
    ]
  }
};

// 2. Improved function with error handling 
function goToScene(sceneKey) {
  const scene = scenes[sceneKey];

  // Check if the scene exists 
  if (!scene) {
    console.error(`Error: Scene "${sceneKey}" was not found in the scenes object!`);
    return;
  }

  // 1. Find the image element by ID or by class
  const imgEl = document.getElementById('scene-image') || document.querySelector('.scene-image');
  if (imgEl) {
    imgEl.src = scene.bg;
  }

  // 2. Find the text element by ID
  const textEl = document.getElementById('story-text');
  if (textEl) {
    textEl.innerText = scene.text;
  }

  // 3. Find the container for the choice buttons by ID or by class
  const choicesDiv = document.getElementById('choices') || document.querySelector('.choices');
  if (choicesDiv) {
    choicesDiv.innerHTML = ''; // Clear the old buttons 

    scene.choices.forEach(choice => {
      const button = document.createElement('button');
      button.innerText = choice.text;

      // Handle the button click 
      button.onclick = () => goToScene(choice.next);

      choicesDiv.appendChild(button);
    });
  }
}

// 3. Start the game 
goToScene('start');






