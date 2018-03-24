package Regexp::Pattern::JSON;

# DATE
# VERSION

our %RE;

$RE{number} = {
    summary => 'Match a JSON number literal',
    pat => qr{(?:
  (
    -?
    (?: 0 | [1-9][0-9]* )
    (?: \. [0-9]+ )?
    (?: [eE] [-+]? [0-9]+ )?
  )
    )}x,
};

$RE{string} = {
    summary => 'Match a JSON string literal',
    pat => qr{(?:
    "
    (?:
        [^\\"]+
    |
        \\ [0-7]{1,3}
    |
        \\ x [0-9A-Fa-f]{1,2}
    |
        \\ ["\\/bfnrt]
    #|
    #    \\ u [0-9a-fA-f]{4}
    )*
    "
    )}xms,
};

our $define = qr{

(?(DEFINE)

(?<OBJECT>
  \{\s*
    (?:
        (?&KV)
        \s*
        (?:,\s* (?&KV))*
    )?
    \s*
  \}
)

(?<KV>
  (?&STRING)
  \s*
  (?::\s* (?&VALUE))
)

(?<ARRAY>
  \[\s*
  (?:
      (?&VALUE)
      (?:\s*,\s* (?&VALUE))*
  )?
  \s*
  \]
)

(?<VALUE>
  \s*
  (?:
      (?&STRING)
  |
      (?&NUMBER)
  |
      (?&OBJECT)
  |
      (?&ARRAY)
  |
      true
  |
      false
  |
      null
  )
  \s*
)

(?<STRING> $RE{string}{pat})

(?<NUMBER> $RE{number}{pat})

) # DEFINE

}xms;

$RE{array} = {
    summary => 'Match a JSON array',
    pat => qr{(?:
    (?&ARRAY)
$define
    )}xms,
};

$RE{object} = {
    summary => 'Match a JSON object (a.k.a. hash/dictionary)',
    pat => qr{(?:
    (?&OBJECT)
$define
    )}xms,
};

$RE{value} = {
    summary => 'Match a JSON value',
    pat => qr{(?:
    (?&VALUE)
$define
    )}xms,
};
