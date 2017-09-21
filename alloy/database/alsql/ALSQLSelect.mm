//
//  ALSQLSelect.m
//  alloy
//
//  Created by Alex Lee on 19/08/2017.
//  Copyright © 2017 Alex Lee. All rights reserved.
//

#import "ALSQLSelect.h"
#import "ALSQLValue.h"
#import "ALDBResultColumn.h"
#import "ALSQLClause.h"

@implementation ALSQLSelect{
    BOOL _distinct;
    ALDBResultColumnList              _resultColumns;
    std::list<const ALSQLClause>      _tablesOrSubQueries;

    ALSQLExpr   _where;
    ALSQLClause _groupBy;
    ALSQLClause _having;
    ALSQLClause _orderBy;
    ALSQLClause _offset;
    ALSQLClause _limit;
}

- (const ALDBResultColumnList &)resultColumns {
    return _resultColumns;
}

- (instancetype)select:(const ALDBResultColumnList &)columns distinct:(BOOL)distinct {
    _resultColumns.insert(_resultColumns.end(), columns.begin(), columns.end());
    _distinct = distinct;
    return self;
}

- (instancetype)from:(NSString *)table {
    _tablesOrSubQueries.insert(_tablesOrSubQueries.end(), table);
    return self;
}

- (instancetype)where:(const ALDBCondition &)conditions {
    _where = _where && conditions;
    return self;
}

- (instancetype)groupBy:(const std::list<const ALSQLExpr> &)exprList {
    for (auto expr : exprList) {
        if (!_groupBy.is_empty()) {
            _groupBy.append(@", ");
        }
        _groupBy.append(expr);
    }
    return self;
}

- (instancetype)having:(const ALSQLExpr &)having {
    _having = having;
    return self;
}

- (instancetype)orderBy:(const std::list<const ALSQLExpr> &)exprlist {
    for (auto expr : exprlist) {
        if (!_orderBy.is_empty()) {
            _orderBy.append(@", ");
        }
        _orderBy.append(expr);
    }
    return self;
}

- (instancetype)limit:(const ALSQLExpr &)limit {
    _limit = limit;
    return self;
}

- (instancetype)offset:(const ALSQLExpr &)offset {
    _offset = offset;
    return self;
}

- (const ALSQLClause)SQLClause {
    ALSQLClause clause("SELECT ");
    clause.append(ALSQLClause::combine<ALSQLClause, ALDBResultColumn>(_resultColumns, ", "));

    clause.append(" FROM ");
    clause.append(ALSQLClause::combine<ALSQLClause, ALSQLClause>(_tablesOrSubQueries, ", "));

    if (!_where.is_empty()) {
        clause.append(" WHERE ").append(_where);
    }

    if (!_groupBy.is_empty()) {
        clause.append(" GROUP BY ").append(_groupBy);

        if (!_having.is_empty()) {
            clause.append(" HAVING ").append(_having);
        }
    }

    if (!_orderBy.is_empty()) {
        clause.append(" ORDER BY ").append(_orderBy);
    }

    if (!_limit.is_empty()) {
        clause.append(" LIMIT ").append(_limit);
    }

    if (!_offset.is_empty()) {
        clause.append(" OFFSET ").append(_offset);
    }
    return clause;
}

@end
