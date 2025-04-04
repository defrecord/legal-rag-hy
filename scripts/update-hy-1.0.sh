#!/usr/bin/env bash
# Script to update Hy code for 1.0 compatibility

# Function to replace in files
replace_in_files() {
    find src tests -name "*.hy" -exec sed -i "$1" {} \;
}

# 1. Update import syntax (colon needs space in Hy 1.0)
replace_in_files 's/\(import\([^:]*\):\([^[:space:]]\)/\(import\1 :\2/g'

# 2. Update decorator syntax
replace_in_files 's/@(\([^)]*\))/\(with-decorator \1/g'

# 3. Fix underscores in function names (_generate_embedding_api -> _generate-embedding-api)
replace_in_files 's/_generate_embedding_api/self._generate-embedding-api/g'

# 4. Update dataclass syntax (remove ^types for dataclass fields)
replace_in_files 's/(\^[a-zA-Z][a-zA-Z0-9]*\s\([^)]*\))/\1/g'

# 5. Update dictionary access with get - ensure proper space after get
replace_in_files 's/\(get\([^[:space:]]\)/\(get \1/g'

# 6. Fix let bindings to ensure proper list format
replace_in_files 's/\(let \[\([^]]*\)]/\(let \[\1]/g'

echo "Updated Hy files for 1.0 compatibility"