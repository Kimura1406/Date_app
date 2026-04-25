package repository

import (
	"fmt"
	"strings"
)

func parseTextArray(raw string) ([]string, error) {
	raw = strings.TrimSpace(raw)
	if raw == "" {
		return []string{}, nil
	}
	if raw == "{}" {
		return []string{}, nil
	}
	if len(raw) < 2 || raw[0] != '{' || raw[len(raw)-1] != '}' {
		return nil, fmt.Errorf("invalid postgres array: %q", raw)
	}

	values := make([]string, 0)
	var current strings.Builder
	inQuotes := false
	escaped := false

	appendValue := func() {
		values = append(values, current.String())
		current.Reset()
	}

	for _, ch := range raw[1 : len(raw)-1] {
		switch {
		case escaped:
			current.WriteRune(ch)
			escaped = false
		case ch == '\\':
			escaped = true
		case ch == '"':
			inQuotes = !inQuotes
		case ch == ',' && !inQuotes:
			appendValue()
		default:
			current.WriteRune(ch)
		}
	}

	if inQuotes || escaped {
		return nil, fmt.Errorf("invalid postgres array encoding: %q", raw)
	}

	appendValue()
	for i := range values {
		values[i] = strings.TrimSpace(values[i])
	}
	return values, nil
}
