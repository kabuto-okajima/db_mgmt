from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parent.parent


@dataclass(frozen=True)
class QueryParameter:
    name: str
    description: str
    default: str | int
    value_type: type[str] | type[int]


@dataclass(frozen=True)
class CannedQuery:
    query_id: str
    title: str
    description: str
    sql_path: Path
    parameters: tuple[QueryParameter, ...] = ()

    @property
    def relative_sql_path(self) -> str:
        return str(self.sql_path.relative_to(REPO_ROOT))


def _sql(path: str) -> Path:
    return REPO_ROOT / path


QUERY_REGISTRY: tuple[CannedQuery, ...] = (
    CannedQuery(
        query_id="basic-cbp-monthly-state-totals",
        title="CBP monthly state totals",
        description="Shows monthly encounter totals by state from the CBP fact table.",
        sql_path=_sql("sql/analysis/basic/01_basic_cbp_monthly_state_totals.sql"),
    ),
    CannedQuery(
        query_id="basic-ohss-state-metric-totals",
        title="OHSS state metric totals",
        description="Shows annual totals for selected OHSS immigration outcome metrics by state.",
        sql_path=_sql("sql/analysis/basic/02_basic_ohss_state_metric_totals.sql"),
    ),
    CannedQuery(
        query_id="basic-niv-monthly-country-class",
        title="NIV monthly country totals by visa class",
        description="Shows monthly DOS NIV issuances for one visa class across countries.",
        sql_path=_sql("sql/analysis/basic/03_basic_niv_monthly_country_class.sql"),
        parameters=(
            QueryParameter("visa_class_code", "NIV visa class to analyze.", "F1", str),
            QueryParameter("start_yyyymm", "Inclusive start period in YYYYMM form.", 202301, int),
            QueryParameter("end_yyyymm", "Inclusive end period in YYYYMM form.", 202508, int),
        ),
    ),
    CannedQuery(
        query_id="basic-iv-monthly-country-class-basis",
        title="IV monthly country totals by class and basis",
        description="Shows monthly DOS IV issuances for one IV class while preserving basis.",
        sql_path=_sql("sql/analysis/basic/04_basic_iv_monthly_country_class_basis.sql"),
        parameters=(
            QueryParameter("iv_visa_class_code", "IV visa class to analyze.", "IR1", str),
            QueryParameter("start_yyyymm", "Inclusive start period in YYYYMM form.", 202301, int),
            QueryParameter("end_yyyymm", "Inclusive end period in YYYYMM form.", 202508, int),
        ),
    ),
    CannedQuery(
        query_id="story-cbp-top-citizenships-in-state-period",
        title="CBP top citizenships in one state and period",
        description="Finds the top citizenship groups encountered in a selected state and time range.",
        sql_path=_sql("sql/analysis/storyline/01_story_cbp_top_citizenships_in_state_period.sql"),
        parameters=(
            QueryParameter("state_name", "State name to analyze.", "Texas", str),
            QueryParameter("start_yyyymm", "Inclusive start period in YYYYMM form.", 202301, int),
            QueryParameter("end_yyyymm", "Inclusive end period in YYYYMM form.", 202508, int),
        ),
    ),
    CannedQuery(
        query_id="story-cbp-country-breakdown-in-state",
        title="CBP demographic and authority breakdown for one country and state",
        description="Breaks down CBP encounters for one country within one state and time range.",
        sql_path=_sql("sql/analysis/storyline/02_story_cbp_venezuela_breakdown_in_texas.sql"),
        parameters=(
            QueryParameter("state_name", "State name to analyze.", "Texas", str),
            QueryParameter("country_name", "Country name to analyze.", "Venezuela", str),
            QueryParameter("start_yyyymm", "Inclusive start period in YYYYMM form.", 202301, int),
            QueryParameter("end_yyyymm", "Inclusive end period in YYYYMM form.", 202508, int),
        ),
    ),
    CannedQuery(
        query_id="story-ohss-selected-metrics",
        title="OHSS selected metrics for one state",
        description="Shows selected OHSS totals and per-million values for one state over a year range.",
        sql_path=_sql("sql/analysis/storyline/03_story_ohss_texas_selected_metrics.sql"),
        parameters=(
            QueryParameter("state_name", "State name to analyze.", "Texas", str),
            QueryParameter("start_year", "Inclusive start year.", 2021, int),
            QueryParameter("end_year", "Inclusive end year.", 2023, int),
        ),
    ),
    CannedQuery(
        query_id="story-niv-selected-classes",
        title="NIV selected classes for one country",
        description="Shows monthly NIV issuances for a selected country across the built-in story classes.",
        sql_path=_sql("sql/analysis/storyline/04_story_niv_venezuela_selected_classes.sql"),
        parameters=(
            QueryParameter("country_name", "Country name to analyze.", "Venezuela", str),
            QueryParameter("start_yyyymm", "Inclusive start period in YYYYMM form.", 202301, int),
            QueryParameter("end_yyyymm", "Inclusive end period in YYYYMM form.", 202508, int),
        ),
    ),
    CannedQuery(
        query_id="story-iv-basis-totals",
        title="IV basis totals for one country",
        description="Shows monthly IV issuances by basis for a selected country.",
        sql_path=_sql("sql/analysis/storyline/05_story_iv_venezuela_basis_totals.sql"),
        parameters=(
            QueryParameter("country_name", "Country name to analyze.", "Venezuela", str),
            QueryParameter("start_yyyymm", "Inclusive start period in YYYYMM form.", 202301, int),
            QueryParameter("end_yyyymm", "Inclusive end period in YYYYMM form.", 202508, int),
        ),
    ),
    CannedQuery(
        query_id="story-cross-dataset-summary",
        title="Cross-dataset summary for one state and country",
        description="Combines CBP, OHSS, NIV, and IV summary rows for a selected state and country.",
        sql_path=_sql("sql/analysis/storyline/06_story_cross_dataset_texas_venezuela_summary.sql"),
        parameters=(
            QueryParameter("state_name", "State name to analyze.", "Texas", str),
            QueryParameter("country_name", "Country name to analyze.", "Venezuela", str),
            QueryParameter("start_yyyymm", "Inclusive start period in YYYYMM form.", 202301, int),
            QueryParameter("end_yyyymm", "Inclusive end period in YYYYMM form.", 202508, int),
            QueryParameter("start_year", "Inclusive start year for OHSS rows.", 2023, int),
            QueryParameter("end_year", "Inclusive end year for OHSS rows.", 2023, int),
        ),
    ),
)

QUERY_BY_ID = {query.query_id: query for query in QUERY_REGISTRY}
