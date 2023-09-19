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
    method fOpen($filename,$open_as) {
        my $fh := NQPFileHandle.new();
        my $f := $fh.wrap(nqp::open($filename,$open_as));
        return $f;
    }
    method fWrite($f, $str) {
        $f.print($str);
    }
    method fRead($f) {
        return $f.slurp();
    }
    method fClose($f) {
        return $f.close();
    }
}