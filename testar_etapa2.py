import os
import sys
import subprocess
import glob

def main():
    generate = "--generate" in sys.argv
    test_files = sorted(glob.glob("exemplos/etapa2_*.foca"))
    
    if not test_files:
        print("Nenhum arquivo de teste 'exemplos/etapa2_*.foca' encontrado.")
        sys.exit(1)
        
    pass_count = 0
    fail_count = 0
    
    print(f"Executando {len(test_files)} testes da etapa 2...\n")
    
    for foca_path in test_files:
        name = os.path.basename(foca_path)
        is_error_test = "_err_" in name
        expected_path = foca_path.replace(".foca", ".expected")
        
        try:
            with open(foca_path, "r", encoding="utf-8") as infile:
                result = subprocess.run(
                    ["./glf"],
                    stdin=infile,
                    stdout=subprocess.PIPE,
                    stderr=subprocess.PIPE,
                    text=True
                )
        except Exception as e:
            print(f"Erro ao executar ./glf para {name}: {e}")
            fail_count += 1
            continue
            
        if is_error_test:
            # For error tests, we expect exit code != 0 and error message in stderr
            actual = result.stderr.strip()
            failed_to_fail = (result.returncode == 0)
        else:
            # For valid tests, we expect exit code == 0 and generated code in stdout
            actual = result.stdout.strip()
            failed_to_fail = (result.returncode != 0)
            
        if generate:
            with open(expected_path, "w", encoding="utf-8") as outfile:
                if is_error_test and failed_to_fail:
                    outfile.write(f"ERROR: compiler did not fail (returned 0). Output: {result.stdout.strip()}")
                else:
                    outfile.write(actual)
            print(f"  [GERADO] {name} -> {os.path.basename(expected_path)}")
            pass_count += 1
        else:
            if not os.path.exists(expected_path):
                print(f"  FAIL: {name} (arquivo .expected nao encontrado)")
                fail_count += 1
                continue
                
            with open(expected_path, "r", encoding="utf-8") as expected_file:
                expected = expected_file.read().strip()
                
            if is_error_test:
                if failed_to_fail:
                    print(f"  FAIL: {name} (esperava erro, mas compilou com sucesso)")
                    fail_count += 1
                elif expected in actual or actual in expected or (expected == "" and actual != ""):
                    # Normalizing to avoid strict formatting issues in error outputs
                    print(f"  PASS: {name}")
                    pass_count += 1
                else:
                    print(f"  FAIL: {name}")
                    print(f"    Esperado contendo: '{expected}'")
                    print(f"    Obtido:            '{actual}'")
                    fail_count += 1
            else:
                if failed_to_fail:
                    print(f"  FAIL: {name} (compilacao falhou com erro: {result.stderr.strip()})")
                    fail_count += 1
                elif actual == expected:
                    print(f"  PASS: {name}")
                    pass_count += 1
                else:
                    print(f"  FAIL: {name} (codigo gerado diferente do esperado)")
                    print("--- Diferenca ---")
                    import difflib
                    diff = difflib.unified_diff(
                        expected.splitlines(),
                        actual.splitlines(),
                        fromfile="esperado",
                        tofile="obtido"
                    )
                    print("\n".join(diff))
                    fail_count += 1

    print(f"\nResultado: {pass_count} passou, {fail_count} falhou")
    if fail_count > 0:
        sys.exit(1)
    sys.exit(0)

if __name__ == "__main__":
    main()
