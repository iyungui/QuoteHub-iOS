# QuoteHub 배포·인프라 핸드오프

> 최종 업데이트: 2026-07-25
> 이 문서는 백엔드 호스팅 이전과 iOS 배포 파이프라인 구축 작업의 요약·인수인계다.
> 다음 작업자(또는 다음 세션)가 이것만 읽어도 배포와 잔재 정리를 이어갈 수 있게 정리했다.

---

## 1. 지금까지 한 일 (2026-07-25)

**목표**: 백엔드를 Render 무료(15분 유휴 스핀다운, 복귀 30~60초)에서 **끊기지 않는 무료**
환경으로 옮기고, 이후 서버를 옮겨도 앱 재배포가 필요 없게 만든다.

### 백엔드: Render → Google Cloud Run
- Cloud Run에 배포 완료·검증됨 (서울 리전). 유휴 시 0으로 축소되지만 요청 오면 1~3초 복귀,
  Render식 스핀다운·인스턴스시간 소진·유휴 회수 없음.
- DB(MongoDB Atlas)·이미지(S3)는 그대로 재사용 → 데이터 이전 0.
- 상세: `QuoteHub-server/CLOUD_RUN_DEPLOY.md`

### 앞단: Cloudflare Worker 커스텀 도메인
- 앱은 **`https://quotehub-api.iyungui.dev`** 를 호출한다.
- 경로: `앱 → Cloudflare Worker(quotehub-api-proxy) → Cloud Run → Atlas/S3`
- **핵심**: 백엔드를 옮길 땐 Worker의 `ORIGIN` 한 줄만 바꾸고 `npx wrangler deploy` →
  앱은 안 건드려도 된다. 이번 2.15가 그 목적을 위한 마지막 강제 배포.
- 도메인 `iyungui.dev`는 Cloudflare Registrar 등록, 만료 **2029-07-25**.
- 상세: `QuoteHub-server/cloudflare/README.md`, `cloudflare/DOMAIN-GUIDE.md`

### iOS: 서버 주소 일원화 + fastlane
- `EndpointProtocol.swift`의 `ServerEnvironment.production` = `quotehub-api.iyungui.dev`
  (DEBUG/RELEASE 분기 일원화). 서버 주소를 참조하는 유일한 지점.
- fastlane 배포 파이프라인 구축 (아래 2절).

### 이전 중 발견·수정한 잠복 버그 2건 (macOS 로컬에선 안 터지던 것)
1. `QuoteHub-server/.env`의 AWS 키 2개가 뒤바뀜 → S3 업로드 실패 상태였음. 교정·검증 완료.
   ⚠️ **Render 대시보드 환경변수도 같은 실수인지 확인 필요.**
2. 라우트 require 대소문자 불일치 2건(`bookstoriesComments.js`, `Folders.js`) →
   Linux(Cloud Run)에서 컨테이너 기동 실패. 실제 파일명으로 수정.

### Git 상태
- `QuoteHub-server` (main): 커밋·푸시 완료.
- `QuoteHub-iOS`(구 QuoteHub-Frontend, main): study/deep-dive-phase0 머지 후 커밋·푸시 완료.
  main에 커스텀 도메인 URL + fastlane + 랜덤 닉네임 기능 반영됨. **2.15는 main에서 빌드.**
  (원격이 QuoteHub-Frontend → QuoteHub-iOS로 rename됨. 로컬 remote는 아직 옛 URL이지만
  리다이렉트로 push 정상. 정리하려면 `git remote set-url origin
  https://github.com/iyungui/QuoteHub-iOS.git`)

---

## 2. iOS 배포 방법 (fastlane) — ★ 다음 세션 필독

### 사전 준비 (이미 완료됨, 재설치 시에만)
- App Store Connect **API 키** 인증 사용.
- `fastlane/.env` (gitignore됨, 로컬에만 존재):
  ```
  ASC_KEY_ID=957VFDD6L4
  ASC_ISSUER_ID=<issuer id>
  ASC_KEY_PATH=./fastlane/AuthKey_957VFDD6L4.p8
  ```
- `.p8` 키 파일은 `fastlane/` 안에 있음 (gitignore됨). **분실 주의 — 재발급 불가.**
- 앱 정보: 번들 `com.yungui.QuoteHub`, 팀 `285ZKW5MPR`, App ID `6469527373`.

### 명령
```bash
cd QuoteHub-Frontend        # (현 폴더명 기준)
bundle install              # 최초 1회

bundle exec fastlane beta                 # TestFlight 업로드 (내부 테스트)
bundle exec fastlane release              # App Store 업로드 (자동 제출 안 함)
bundle exec fastlane release version:2.15 # 마케팅 버전까지 올려서
```

### 알아야 할 것
- **반드시 `main` 브랜치(또는 iyungui.dev URL이 들어있는 브랜치)에서 빌드.** 다른 브랜치엔
  옛 서버 주소가 있을 수 있다.
- 빌드 번호는 **자동 증가**(TestFlight 최신 +1을 빌드 시 xcargs로 주입). pbxproj 안 건드림.
- `release`는 **업로드까지만** 한다. 실제 심사는 App Store Connect에서 **"심사 제출" 버튼**을
  사람이 눌러야 시작된다 (Fastfile `submit_for_review: false`).
- **사용자 터미널에서 실행할 것.** 코드 서명 시 macOS 키체인 팝업이 뜰 수 있어 자동화
  환경에선 멈춘다. 아카이브+업로드에 5~10분.
- 이전 버전: 2.14 (build 8). 다음 출시: 2.15.
- ⚠️ fastlane 실행 시 `fastlane/README.md`가 자동 재생성되어 덮어써진다(정상 동작).

---

## 3. 잔재 정리 TODO

### 🔴 2.15가 App Store에 실제 출시된 것을 확인한 "후에" 할 것
- [ ] **Render 서비스 삭제.** 그 전엔 절대 금지 — 옛 빌드 유저가 아직 Render를 본다.
      심사 반려·지연 대비 보험.
- [ ] 삭제 후 `QuoteHub-server`의 `render.yaml`, `RENDER_DEPLOY_GUIDE.md` 제거.

### 🟡 지금 할 수 있는 것
- [ ] **Uptime 모니터를 새 주소로 재설정**: 감시 대상을 `quotehub-api.iyungui.dev/health`로.
      Render URL 핑은 중단(Render 무료 750시간 한도 보호). 삭제가 아니라 "재조준".
- [ ] **도메인 자동 갱신(Auto-renew) ON 확인** (Cloudflare 대시보드). 만료 시 전 서비스 중단.
- [ ] Render 대시보드의 AWS 키가 뒤바뀌어 있는지 확인 (위 1절 버그와 동일 여부).

### 🟢 선택 (여유 될 때)
- [ ] `npm audit` 취약점 정리 (핵심은 `multer` 2.x 업그레이드, breaking change).
- [ ] `Info.plist`의 `NSAllowsArbitraryLoads = true` 범위 축소(로컬 개발만 허용하도록).
- [ ] GCP: 실패한 첫 Cloud Run 리비전·오래된 빌드 이미지 정리, Artifact Registry 정리 정책.
- [ ] (원하면) GitHub Actions로 fastlane CI/CD 자동화 — 지금은 수동 실행. ASC 키를 GitHub
      Secret으로 넣고 CI 서명 설정 필요.
- [ ] `git remote set-url origin https://github.com/iyungui/QuoteHub-iOS.git` (레포 rename 반영).

---

## 4. 아키텍처 요약

```
iOS 앱 (문장모아, com.yungui.QuoteHub)
  └→ https://quotehub-api.iyungui.dev          ← 앱에 박힌 고정 주소
       └→ Cloudflare Worker (quotehub-api-proxy) ← 백엔드 이전 시 여기 ORIGIN만 변경
            └→ Cloud Run (quotehub-server, GCP quotehub-436306, asia-northeast3)
                 ├→ MongoDB Atlas (yungui.t1xxoys.mongodb.net, Network Access 0.0.0.0/0)
                 └→ AWS S3 (이미지)
```

관련 문서:
- `QuoteHub-server/CLOUD_RUN_DEPLOY.md` — Cloud Run 배포·운영·롤백
- `QuoteHub-server/cloudflare/README.md` — Worker 프록시
- `QuoteHub-server/cloudflare/DOMAIN-GUIDE.md` — iyungui.dev로 블로그/다른 앱 얹기
