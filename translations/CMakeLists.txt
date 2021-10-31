
find_package(Qt6 COMPONENTS LinguistTools REQUIRED)

qt_add_lrelease(metronomek
    TS_FILES metronomek_pl.ts
    QM_FILES_OUTPUT_VARIABLE qm_files
)

install(FILES ${qm_files} DESTINATION "translations")
