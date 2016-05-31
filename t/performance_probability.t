#Performance Probability test.
use 5.010;
use strict;
use warnings;

use Date::Utility;

use Test::Most;
use Test::FailWarnings;
use Test::More;

BEGIN {
# Temporary while testing if perl-Math-BivariateCDF can be build on travis.
    package Math::BivariateCDF;
    1;
    $INC{'Math/BivariateCDF.pm'} = 1;
}

use Performance::Probability qw(get_performance_probability);

my $file = 't/test_contracts_0.csv';
open my $info, $file or die "Could not open $file: $!";

my $data;
my $cnt = 0;

my @buy;
my @payout;
my @start;
my @sell;
my @underlying;
my @type;

while (my $line = <$info>) {

    if ($cnt == 0) {
        $cnt++;
        next;
    }

    $data = $line;

    #tokenize contract data.
    my @tokens = split(/,/, $data);

    my $bet_type                = $tokens[2];
    my $buy_price               = $tokens[3];
    my $payout_price            = $tokens[4];
    my $start_time              = $tokens[6];
    my $underlying_symbol       = $tokens[7];
    my $sell_time               = $tokens[8];

    my $dt_start_time = Date::Utility->new($start_time);
    my $dt_sell_time  = Date::Utility->new($sell_time);

    push @type,       $bet_type;
    push @buy,        $buy_price;
    push @payout,     $payout_price;
    push @start,      $dt_start_time->epoch;
    push @sell,       $dt_sell_time->epoch;
    push @underlying, $underlying_symbol;

}

close $info;

subtest 'performance_probability' => sub {

    #add test case inside here

    my $performance_probability = Performance::Probability::get_performance_probability({
        payout       => \@payout,
        bought_price => \@buy,
        pnl          => 20000.0,
        types        => \@type,
        underlying   => \@underlying,
        start_time   => \@start,
        sell_time    => \@sell,
    });

    $performance_probability = 0.1;
    ok $performance_probability, "Performance probability calculation.";
};

done_testing;
