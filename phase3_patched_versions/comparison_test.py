#!/usr/bin/env python3
"""
Phase 3: 취약 버전 vs 패치 버전 비교 테스트
"""
import sys
import time
from opcua import Client, ua
from opcua.ua.uaerrors import UaError

# 색상 코드
GREEN = '\033[0;32m'
RED = '\033[0;31m'
YELLOW = '\033[1;33m'
BLUE = '\033[0;34m'
NC = '\033[0m'

# 서버 정보
SERVERS = {
    'vulnerable': {
        's2opc': {
            'url': 'opc.tcp://localhost:4840/S2OPC/server/',
            'version': 'v1.4.0',
            'port': 4840
        },
        'python': {
            'url': 'opc.tcp://localhost:4841/freeopcua/server/',
            'version': 'v0.98.13',
            'port': 4841
        },
        'open62541': {
            'url': 'opc.tcp://localhost:4842/open62541/server/',
            'version': 'v1.3.8',
            'port': 4842
        }
    },
    'patched': {
        's2opc': {
            'url': 'opc.tcp://localhost:5840/S2OPC/server/',
            'version': 'v1.6.0',
            'port': 5840
        },
        'python': {
            'url': 'opc.tcp://localhost:5843/asyncua/server/',
            'version': 'asyncio v1.1.8',
            'port': 5843
        },
        'open62541': {
            'url': 'opc.tcp://localhost:5842/open62541/server/',
            'version': 'v1.4.14',
            'port': 5842
        }
    }
}

def print_header(title):
    """헤더 출력"""
    print(f"\n{BLUE}{'='*70}{NC}")
    print(f"{BLUE}{title:^70}{NC}")
    print(f"{BLUE}{'='*70}{NC}\n")

def test_anonymous_connection(url, version, implementation):
    """Anonymous 인증 테스트"""
    try:
        client = Client(url, timeout=3)
        client.connect()
        
        # 서버 상태 확인
        root = client.get_root_node()
        server_time = root.get_child(["0:Objects", "0:Server", "0:ServerStatus", "0:CurrentTime"])
        current_time = server_time.get_value()
        
        client.disconnect()
        return {
            'success': True,
            'message': f'✅ Anonymous 연결 성공',
            'time': str(current_time)[:19]
        }
    except Exception as e:
        return {
            'success': False,
            'message': f'❌ 연결 실패',
            'error': str(e)[:50]
        }

def test_get_endpoints(url, version, implementation):
    """GetEndpoints 요청으로 보안 정책 확인"""
    try:
        client = Client(url, timeout=3)
        endpoints = client.connect_and_get_server_endpoints()
        
        policies = set()
        for endpoint in endpoints:
            policy = endpoint.SecurityPolicyUri
            if policy:
                policy_name = policy.split('#')[-1] if '#' in policy else policy
                policies.add(policy_name)
        
        has_nosecurity = 'None' in policies or len(policies) == 0
        
        return {
            'success': True,
            'policies': list(policies) if policies else ['None'],
            'has_nosecurity': has_nosecurity,
            'endpoint_count': len(endpoints)
        }
    except Exception as e:
        return {
            'success': False,
            'error': str(e)[:50]
        }

def test_read_operation(url, version, implementation):
    """Read 작업 테스트"""
    try:
        client = Client(url, timeout=3)
        client.connect()
        
        # 루트 노드 읽기
        root = client.get_root_node()
        browse_name = root.get_browse_name()
        
        client.disconnect()
        return {
            'success': True,
            'message': f'✅ Read 성공',
            'data': str(browse_name)
        }
    except Exception as e:
        return {
            'success': False,
            'message': f'❌ Read 실패',
            'error': str(e)[:50]
        }

def run_comparison_tests():
    """전체 비교 테스트 실행"""
    print(f"\n{GREEN}╔═══════════════════════════════════════════════════════════════════╗{NC}")
    print(f"{GREEN}║         Phase 3: 취약 버전 vs 패치 버전 비교 테스트              ║{NC}")
    print(f"{GREEN}╚═══════════════════════════════════════════════════════════════════╝{NC}")
    
    results = {
        'vulnerable': {},
        'patched': {}
    }
    
    for version_type in ['vulnerable', 'patched']:
        version_name = '취약 버전' if version_type == 'vulnerable' else '패치 버전'
        port_range = '4840-4842' if version_type == 'vulnerable' else '5840-5842'
        
        print_header(f"{version_name} 테스트 (포트: {port_range})")
        
        for impl_name, impl_info in SERVERS[version_type].items():
            impl_display = impl_name.upper() if impl_name != 'python' else 'Python opcua'
            print(f"\n{YELLOW}📊 {impl_display} {impl_info['version']}{NC}")
            print(f"   URL: {impl_info['url']}")
            print(f"   포트: {impl_info['port']}")
            print()
            
            # 1. Anonymous 연결 테스트
            print("   1️⃣  Anonymous 연결 테스트...")
            anon_result = test_anonymous_connection(
                impl_info['url'],
                impl_info['version'],
                impl_name
            )
            print(f"      {anon_result['message']}")
            if anon_result['success']:
                print(f"      시간: {anon_result['time']}")
            
            # 2. GetEndpoints 테스트
            print("\n   2️⃣  보안 정책 확인 (GetEndpoints)...")
            endpoints_result = test_get_endpoints(
                impl_info['url'],
                impl_info['version'],
                impl_name
            )
            if endpoints_result['success']:
                policies = ', '.join(endpoints_result['policies'])
                nosec_status = f"{RED}있음 ⚠️{NC}" if endpoints_result['has_nosecurity'] else f"{GREEN}없음 ✅{NC}"
                print(f"      보안 정책: {policies}")
                print(f"      NoSecurity: {nosec_status}")
                print(f"      Endpoint 수: {endpoints_result['endpoint_count']}")
            else:
                print(f"      ❌ 실패: {endpoints_result['error']}")
            
            # 3. Read 작업 테스트
            print("\n   3️⃣  Read 작업 테스트...")
            read_result = test_read_operation(
                impl_info['url'],
                impl_info['version'],
                impl_name
            )
            print(f"      {read_result['message']}")
            
            # 결과 저장
            if impl_name not in results[version_type]:
                results[version_type][impl_name] = {}
            
            results[version_type][impl_name] = {
                'anonymous': anon_result,
                'endpoints': endpoints_result,
                'read': read_result
            }
            
            print(f"\n   {'─'*60}")
    
    # 비교 요약 출력
    print_comparison_summary(results)
    
    return results

def print_comparison_summary(results):
    """비교 요약 출력"""
    print(f"\n{GREEN}╔═══════════════════════════════════════════════════════════════════╗{NC}")
    print(f"{GREEN}║                        비교 요약                                  ║{NC}")
    print(f"{GREEN}╚═══════════════════════════════════════════════════════════════════╝{NC}\n")
    
    # 테이블 헤더
    print(f"{'구현체':<15} {'버전':<12} {'Anonymous':<12} {'NoSecurity':<12} {'Read':<10}")
    print("─" * 70)
    
    for impl in ['s2opc', 'python', 'open62541']:
        impl_display = impl.upper() if impl != 'python' else 'Python opcua'
        
        # 취약 버전
        vuln = results['vulnerable'][impl]
        vuln_version = SERVERS['vulnerable'][impl]['version']
        vuln_anon = '✅ 성공' if vuln['anonymous']['success'] else '❌ 실패'
        vuln_nosec = '⚠️  있음' if vuln['endpoints'].get('has_nosecurity', False) else '✅ 없음'
        vuln_read = '✅ 성공' if vuln['read']['success'] else '❌ 실패'
        
        print(f"{impl_display:<15} {vuln_version:<12} {vuln_anon:<12} {vuln_nosec:<12} {vuln_read:<10}")
        
        # 패치 버전
        patch = results['patched'][impl]
        patch_version = SERVERS['patched'][impl]['version']
        patch_anon = '✅ 성공' if patch['anonymous']['success'] else '❌ 실패'
        patch_nosec = '⚠️  있음' if patch['endpoints'].get('has_nosecurity', False) else '✅ 없음'
        patch_read = '✅ 성공' if patch['read']['success'] else '❌ 실패'
        
        print(f"{'':<15} {patch_version:<12} {patch_anon:<12} {patch_nosec:<12} {patch_read:<10}")
        print()
    
    print("─" * 70)
    print(f"\n{YELLOW}📝 참고:{NC}")
    print("   • Anonymous: 익명 인증 허용 여부")
    print("   • NoSecurity: 암호화 없는 정책 제공 여부")
    print("   • Read: 기본 읽기 작업 성공 여부")
    print()

if __name__ == "__main__":
    try:
        results = run_comparison_tests()
        
        print(f"\n{GREEN}✅ 비교 테스트 완료!{NC}\n")
        
    except KeyboardInterrupt:
        print(f"\n{YELLOW}⚠️  테스트가 중단되었습니다{NC}")
        sys.exit(1)
    except Exception as e:
        print(f"\n{RED}❌ 오류 발생: {e}{NC}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

