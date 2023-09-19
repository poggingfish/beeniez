my class Std is export {
    method map(&expr, $list) {
        my $new := [];
        for $list {
            $new.push(&expr($_));
        }
        return $new;
    }
    method strList($list) {
        my $str := "[";
        my $comma := 0;
        for $list {
            if $comma {
                $str := $str~",";
            }
            else {
                $comma := 1;
            }
            if (nqp::istype($_, NQPArray)) {
                $str := $str~self.strList($_);
            } else {
                $str := $str~$_;
            }
        }
        $str := $str~"]";
        return $str;
    }

}