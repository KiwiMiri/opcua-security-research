#!/usr/bin/env python3
"""
Step 1: 패치 버전 정보 확인
GitHub API를 사용하여 최신 릴리스 버전을 확인합니다.
"""
import json
import subprocess

def check_latest_version(repo_owner, repo_name, current_version):
    """GitHub에서 최신 버전 확인"""
    print(f"🔍 {repo_owner}/{repo_name} 최신 버전 확인 중...")
    
    try:
        # GitHub API 호출
        cmd = f"curl -s https://api.github.com/repos/{repo_owner}/{repo_name}/releases/latest"
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
        
        if result.returncode == 0 and result.stdout:
            data = json.loads(result.stdout)
            
            if 'tag_name' in data:
                latest = data['tag_name']
                published = data.get('published_at', 'N/A')
                
                print(f"   현재 버전: {current_version}")
                print(f"   최신 버전: {latest}")
                print(f"   릴리스 날짜: {published[:10]}")
                
                # 변경 로그
                if 'body' in data and data['body']:
                    print(f"   주요 변경사항:")
                    lines = data['body'].split('\n')[:5]
                    for line in lines:
                        if line.strip():
                            print(f"      • {line.strip()[:60]}")
                
                print()
                return latest
            else:
                print(f"   ⚠️  최신 릴리스 정보 없음")
                # 태그 목록 확인
                cmd_tags = f"curl -s https://api.github.com/repos/{repo_owner}/{repo_name}/tags"
                result_tags = subprocess.run(cmd_tags, shell=True, capture_output=True, text=True)
                
                if result_tags.returncode == 0:
                    tags = json.loads(result_tags.stdout)
                    if tags and len(tags) > 0:
                        latest_tag = tags[0]['name']
                        print(f"   최신 태그: {latest_tag}")
                        print()
                        return latest_tag
                
                print()
                return None
        else:
            print(f"   ❌ API 호출 실패")
            print()
            return None
            
    except Exception as e:
        print(f"   ❌ 오류: {e}")
        print()
        return None

def main():
    print("╔═══════════════════════════════════════════════════════════════╗")
    print("║        Phase 3 - Step 1: 패치 버전 정보 확인                 ║")
    print("╚═══════════════════════════════════════════════════════════════╝")
    print()
    
    versions = {}
    
    # S2OPC 확인
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("1️⃣  S2OPC")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    versions['S2OPC'] = check_latest_version('systerel', 'S2OPC', 'v1.4.0 (Toolkit_1.4.0)')
    
    # Python opcua 확인
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("2️⃣  Python opcua")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    versions['Python opcua'] = check_latest_version('FreeOpcUa', 'python-opcua', 'v0.98.13')
    
    # open62541 확인
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    print("3️⃣  open62541")
    print("━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    versions['open62541'] = check_latest_version('open62541', 'open62541', 'v1.3.8')
    
    # 요약
    print("╔═══════════════════════════════════════════════════════════════╗")
    print("║                    버전 정보 요약                             ║")
    print("╚═══════════════════════════════════════════════════════════════╝")
    print()
    
    print("📊 버전 비교:")
    print()
    print("┌──────────────┬─────────────────┬─────────────────┬──────────┐")
    print("│ 구현체       │ 현재 (취약)     │ 최신 (패치)     │ 업그레이드│")
    print("├──────────────┼─────────────────┼─────────────────┼──────────┤")
    
    comparisons = [
        ('S2OPC', 'v1.4.0', versions.get('S2OPC', '확인 중')),
        ('Python opcua', 'v0.98.13', versions.get('Python opcua', '확인 중')),
        ('open62541', 'v1.3.8', versions.get('open62541', '확인 중')),
    ]
    
    for name, current, latest in comparisons:
        upgrade = '✅ 필요' if latest and latest != current else '⚠️  확인 필요'
        print(f"│ {name:12} │ {current:15} │ {str(latest)[:15]:15} │ {upgrade:8} │")
    
    print("└──────────────┴─────────────────┴─────────────────┴──────────┘")
    print()
    
    print("╔═══════════════════════════════════════════════════════════════╗")
    print("║                Step 1 완료!                                   ║")
    print("╚═══════════════════════════════════════════════════════════════╝")
    print()
    print("🎯 다음 단계: Step 2 - 패치 버전 설치")
    print()
    
    return versions

if __name__ == "__main__":
    main()
