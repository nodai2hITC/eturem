# coding: utf-8

require "eturem/base"

module Eturem
  class Ja < Base
    
    @inspect_methods = {
      NoMemoryError => :no_memory_error_inspect,
#      ScriptError => :script_error_inspect,
      LoadError => :load_error_inspect,
#      NotImplementedError => :not_implemented_error_inspect,
      SyntaxError => :syntax_error_inspect,
#      SecurityError => :security_error_inspect,
#      SignalException => :signal_exception_inspect,
#      Interrupt => :interrupt_inspect,
#      StandardError => :standard_error_inspect,
      ArgumentError => :argument_error_inspect,
#      UncaughtThrowError => :uncaught_throw_error_inspect,
#      EncodingError => :encoding_error_inspect,
#      Encoding::CompatibilityError => :encoding_compatibility_error_inspect,
#      Encoding::ConverterNotFoundError => :encoding_converter_not_found_error_inspect,
#      Encoding::InvalidByteSequenceError => :encoding_invalid_byte_sequence_error_inspect,
#      Encoding::UndefinedConversionError => :encoding_undefined_conversion_error_inspect,
#      FiberError => :fiber_error_inspect,
#      IOError => :io_error_inspect,
#      EOFError => :eof_error_inspect,
#      IndexError => :index_error_inspect,
#      KeyError => :key_error_inspect,
#      StopIteration => :stop_iteration_inspect,
#      ClosedQueueError => :closed_queue_error_inspect,
#      LocalJumpError => :local_jump_error_inspect,
#      Math::DomainError => :math_domain_error_inspect,
      NameError => :name_error_inspect,
#      NoMethodError => :no_method_error_inspect,
#      RangeError => :range_error_inspect,
#      FloatDomainError => :float_domain_error_inspect,
#      RegexpError => :regexp_error_inspect,
#      RuntimeError => :runtime_error_inspect,
#      FrozenError => :frozen_error_inspect,
#      SystemCallError => :system_call_error_inspect,
#      Errno::E2BIG => :errno_e2big_inspect,
#      Errno::EACCES => :errno_eacces_inspect,
#      Errno::EADDRINUSE => :errno_eaddrinuse_inspect,
#      Errno::EADDRNOTAVAIL => :errno_eaddrnotavail_inspect,
#      Errno::EADV => :errno_eadv_inspect,
#      Errno::EAFNOSUPPORT => :errno_eafnosupport_inspect,
#      Errno::EAGAIN => :errno_eagain_inspect,
#      Errno::EALREADY => :errno_ealready_inspect,
#      Errno::EAUTH => :errno_eauth_inspect,
#      Errno::EBADE => :errno_ebade_inspect,
#      Errno::EBADF => :errno_ebadf_inspect,
#      Errno::EBADFD => :errno_ebadfd_inspect,
#      Errno::EBADMSG => :errno_ebadmsg_inspect,
#      Errno::EBADR => :errno_ebadr_inspect,
#      Errno::EBADRPC => :errno_ebadrpc_inspect,
#      Errno::EBADRQC => :errno_ebadrqc_inspect,
#      Errno::EBADSLT => :errno_ebadslt_inspect,
#      Errno::EBFONT => :errno_ebfont_inspect,
#      Errno::EBUSY => :errno_ebusy_inspect,
#      Errno::ECANCELED => :errno_ecanceled_inspect,
#      Errno::ECAPMODE => :errno_ecapmode_inspect,
#      Errno::ECHILD => :errno_echild_inspect,
#      Errno::ECHRNG => :errno_echrng_inspect,
#      Errno::ECOMM => :errno_ecomm_inspect,
#      Errno::ECONNABORTED => :errno_econnaborted_inspect,
#      Errno::ECONNREFUSED => :errno_econnrefused_inspect,
#      Errno::ECONNRESET => :errno_econnreset_inspect,
#      Errno::EDEADLK => :errno_edeadlk_inspect,
#      Errno::EDEADLOCK => :errno_edeadlock_inspect,
#      Errno::EDESTADDRREQ => :errno_edestaddrreq_inspect,
#      Errno::EDOM => :errno_edom_inspect,
#      Errno::EDOOFUS => :errno_edoofus_inspect,
#      Errno::EDOTDOT => :errno_edotdot_inspect,
#      Errno::EDQUOT => :errno_edquot_inspect,
#      Errno::EEXIST => :errno_eexist_inspect,
#      Errno::EFAULT => :errno_efault_inspect,
#      Errno::EFBIG => :errno_efbig_inspect,
#      Errno::EFTYPE => :errno_eftype_inspect,
#      Errno::EHOSTDOWN => :errno_ehostdown_inspect,
#      Errno::EHOSTUNREACH => :errno_ehostunreach_inspect,
#      Errno::EHWPOISON => :errno_ehwpoison_inspect,
#      Errno::EIDRM => :errno_eidrm_inspect,
#      Errno::EILSEQ => :errno_eilseq_inspect,
#      Errno::EINPROGRESS => :errno_einprogress_inspect,
#      Errno::EINTR => :errno_eintr_inspect,
#      Errno::EINVAL => :errno_einval_inspect,
#      Errno::EIO => :errno_Eio_inspect,
#      Errno::EIPSEC => :errno_eipsec_inspect,
#      Errno::EISCONN => :errno_eisconn_inspect,
#      Errno::EISDIR => :errno_eisdir_inspect,
#      Errno::EISNAM => :errno_eisnam_inspect,
#      Errno::EKEYEXPIRED => :errno_ekeyexpired_inspect,
#      Errno::EKEYREJECTED => :errno_ekeyrejected_inspect,
#      Errno::EKEYREVOKED => :errno_ekeyrevoked_inspect,
#      Errno::EL2HLT => :errno_el2hlt_inspect,
#      Errno::EL2NSYNC => :errno_el2nsync_inspect,
#      Errno::EL3HLT => :errno_el3hlt_inspect,
#      Errno::EL3RST => :errno_el3rst_inspect,
#      Errno::ELIBACC => :errno_elibacc_inspect,
#      Errno::ELIBBAD => :errno_elibbad_inspect,
#      Errno::ELIBEXEC => :errno_elibexec_inspect,
#      Errno::ELIBMAX => :errno_elibmax_inspect,
#      Errno::ELIBSCN => :errno_elibscn_inspect,
#      Errno::ELNRNG => :errno_elnrng_inspect,
#      Errno::ELOOP => :errno_eloop_inspect,
#      Errno::EMEDIUMTYPE => :errno_emediumtype_inspect,
#      Errno::EMFILE => :errno_emfile_inspect,
#      Errno::EMLINK => :errno_emlink_inspect,
#      Errno::EMSGSIZE => :errno_emsgsize_inspect,
#      Errno::EMULTIHOP => :errno_emultihop_inspect,
#      Errno::ENAMETOOLONG => :errno_enametoolong_inspect,
#      Errno::ENAVAIL => :errno_enavail_inspect,
#      Errno::ENEEDAUTH => :errno_eneedauth_inspect,
#      Errno::ENETDOWN => :errno_enetdown_inspect,
#      Errno::ENETRESET => :errno_enetreset_inspect,
#      Errno::ENETUNREACH => :errno_enetunreach_inspect,
#      Errno::ENFILE => :errno_enfile_inspect,
#      Errno::ENOANO => :errno_enoano_inspect,
#      Errno::ENOATTR => :errno_enoattr_inspect,
#      Errno::ENOBUFS => :errno_enobufs_inspect,
#      Errno::ENOCSI => :errno_enocsi_inspect,
#      Errno::ENODATA => :errno_enodata_inspect,
#      Errno::ENODEV => :errno_enodev_inspect,
      Errno::ENOENT => :errno_enoent_inspect,
#      Errno::ENOEXEC => :errno_enoexec_inspect,
#      Errno::ENOKEY => :errno_enokey_inspect,
#      Errno::ENOLCK => :errno_enolck_inspect,
#      Errno::ENOLINK => :errno_enolink_inspect,
#      Errno::ENOMEDIUM => :errno_enomedium_inspect,
#      Errno::ENOMEM => :errno_enomem_inspect,
#      Errno::ENOMSG => :errno_enomsg_inspect,
#      Errno::ENONET => :errno_enonet_inspect,
#      Errno::ENOPKG => :errno_enopkg_inspect,
#      Errno::ENOPROTOOPT => :errno_enoprotoopt_inspect,
#      Errno::ENOSPC => :errno_enospc_inspect,
#      Errno::ENOSR => :errno_enosr_inspect,
#      Errno::ENOSTR => :errno_enostr_inspect,
#      Errno::ENOSYS => :errno_enosys_inspect,
#      Errno::ENOTBLK => :errno_enotblk_inspect,
#      Errno::ENOTCAPABLE => :errno_enotcapable_inspect,
#      Errno::ENOTCONN => :errno_enotconn_inspect,
#      Errno::ENOTDIR => :errno_enotdir_inspect,
#      Errno::ENOTEMPTY => :errno_enotempty_inspect,
#      Errno::ENOTNAM => :errno_enotnam_inspect,
#      Errno::ENOTRECOVERABLE => :errno_enotrecoverable_inspect,
#      Errno::ENOTSOCK => :errno_enotsock_inspect,
#      Errno::ENOTSUP => :errno_enotsup_inspect,
#      Errno::ENOTTY => :errno_enotty_inspect,
#      Errno::ENOTUNIQ => :errno_enotuniq_inspect,
#      Errno::ENXIO => :errno_enxio_inspect,
#      Errno::EOPNOTSUPP => :errno_eopnotsupp_inspect,
#      Errno::EOVERFLOW => :errno_eoverflow_inspect,
#      Errno::EOWNERDEAD => :errno_eownerdead_inspect,
#      Errno::EPERM => :errno_eperm_inspect,
#      Errno::EPFNOSUPPORT => :errno_epfnosupport_inspect,
#      Errno::EPIPE => :errno_epipe_inspect,
#      Errno::EPROCLIM => :errno_eproclim_inspect,
#      Errno::EPROCUNAVAIL => :errno_eprocunavail_inspect,
#      Errno::EPROGMISMATCH => :errno_eprogmismatch_inspect,
#      Errno::EPROGUNAVAIL => :errno_eprogunavail_inspect,
#      Errno::EPROTO => :errno_eproto_inspect,
#      Errno::EPROTONOSUPPORT => :errno_eprotonosupport_inspect,
#      Errno::EPROTOTYPE => :errno_eprototype_inspect,
#      Errno::ERANGE => :errno_erange_inspect,
#      Errno::EREMCHG => :errno_eremchg_inspect,
#      Errno::EREMOTE => :errno_eremote_inspect,
#      Errno::EREMOTEIO => :errno_eremoteio_inspect,
#      Errno::ERESTART => :errno_erestart_inspect,
#      Errno::ERFKILL => :errno_erfkill_inspect,
#      Errno::EROFS => :errno_erofs_inspect,
#      Errno::ERPCMISMATCH => :errno_erpcmismatch_inspect,
#      Errno::ESHUTDOWN => :errno_eshutdown_inspect,
#      Errno::ESOCKTNOSUPPORT => :errno_esocktnosupport_inspect,
#      Errno::ESPIPE => :errno_espipe_inspect,
#      Errno::ESRCH => :errno_esrch_inspect,
#      Errno::ESRMNT => :errno_esrmnt_inspect,
#      Errno::ESTALE => :errno_estale_inspect,
#      Errno::ESTRPIPE => :errno_estrpipe_inspect,
#      Errno::ETIME => :errno_etime_inspect,
#      Errno::ETIMEDOUT => :errno_etimedout_inspect,
#      Errno::ETOOMANYREFS => :errno_etoomanyrefs_inspect,
#      Errno::ETXTBSY => :errno_etxtbsy_inspect,
#      Errno::EUCLEAN => :errno_euclean_inspect,
#      Errno::EUNATCH => :errno_eunatch_inspect,
#      Errno::EUSERS => :errno_eusers_inspect,
#      Errno::EWOULDBLOCK => :errno_ewouldblock_inspect,
#      Errno::EXDEV => :errno_exdev_inspect,
#      Errno::EXFULL => :errno_exfull_inspect,
#      Errno::EXXX => :errno_exxx_inspect,
#      Errno::NOERROR => :errno_noerror_inspect,
#      ThreadError => :thread_error_inspect,
      TypeError => :type_error_inspect,
      ZeroDivisionError => :zero_division_error_inspect,
      SystemStackError => :system_stack_error_inspect,
      "sentinel" => nil
    }
    
    def prepare
      super
      case @exception.class.to_s
      when "DXRuby::DXRubyError"
        @exception_s.force_encoding("sjis") if @exception_s.encoding == Encoding::ASCII_8BIT
        @exception_s.encode!("UTF-8")
      end
    end
    
    def traceback_most_recent_call_last
      "エラー発生までの流れ:"
    end
    
    def location_inspect(location)
      %["#{location.path}" #{location.lineno}行目: '#{location.label}']
    end
    
    def exception_inspect
      return %[ファイル"#{@path}" #{@lineno}行目でエラーが発生しました。\n] + super.to_s
    end
    
    def no_memory_error_inspect
      "メモリを確保できませんでした。あまりにも大量のデータを作成していませんか？"
    end
    
    def load_error_inspect
      %[ファイル/ライブラリ "#{@exception.path}" が見つかりません。] +
      %[ファイル/ライブラリ名を確認してください。]
    end
    
    def syntax_error_inspect
      if @unexpected.match(/^'(.)'$/)
        highlight!(@script_lines[@lineno], Regexp.last_match(1), "\e[31m\e[4m")
      elsif @unexpected.match(/^(?:keyword|modifier)_/)
        highlight!(@script_lines[@lineno], Regexp.last_match.post_match, "\e[31m\e[4m")
      end
      unexpected = transform_syntax_error_keyword(@unexpected)
      expected = @expected.split(/\s+or\s+/).map{ |ex| transform_syntax_error_keyword(ex) }
      keywords = %w[if unless case while until for begin def class module do].select{ |keyword|
        @script.index(keyword)
      }.join(" / ")
      keywords = keywords.empty? ? "ifなど" : "「#{keywords}」"
      
      if expected.join == "end-of-input"
        ret = "構文エラーです。余分な#{unexpected}があります。"
        ret += "#{keywords}と「end」の対応関係を確認してください。" if unexpected == "end"
        return ret
      elsif unexpected == "end-of-input"
        ret = "（ただし、実際のエラーの原因はおそらくもっと前にあります。）\n" +
              "構文エラーです。#{expected.join('または')}が足りません。"
        ret += "#{keywords}に対応する「end」があるか確認してください。" if expected.include?("end")
        return ret
      end
      return "構文エラーです。#{expected.join('または')}が来るべき場所に、" +
             "#{unexpected}が来てしまいました。"
    end
    
    def transform_syntax_error_keyword(keyword)
      case keyword
      when "end-of-input", "$end"
        "end-of-input"
      when /^(?:keyword|modifier)_/
        Regexp.last_match.post_match
      when "'\\n'"
        "改行"
      else
        keyword
      end
    end
    
    def interrupt_inspect
      "プログラムが途中で強制終了されました。"
    end
    
    def argument_error_inspect
      if @given
        ret = "引数の数が正しくありません。「#{@method}」は本来"
        case @expected
        when "0"
          ret += "引数が不要です"
        when /^(\d+)\.\.(\d+)$/
          ret += "#{Regexp.last_match(1)}～#{Regexp.last_match(2)}個の引数を取ります"
        when /^(\d+)\+$/
          ret += "#{Regexp.last_match(1)}個以上の引数を取ります"
        end
        if @given == 0
          ret += "が、引数が１つも渡されていません。"
        else
          ret += "が、#{@given}個の引数が渡されています。"
        end
        return ret
      else
        return "「#{@method}」への引数の数が正しくありません。"
      end
    end
    
    def name_error_inspect
      if @exception.name.to_s.encode("UTF-8").include?("　")
        @output_lines = default_output_lines
        return "スクリプト中に全角空白が混じっています。"
      end
      
      ret = "#{@exception.is_a?(NoMethodError) ? "" : "変数/"}メソッド" +
            "「\e[31m\e[4m#{@exception.name}\e[0m」は存在しません。"
      if @did_you_mean
        did_you_mean = @did_you_mean.map{ |d| "\e[33m#{d}\e[0m" }.join(" / ")
        ret += "「#{did_you_mean}」の入力ミスではありませんか？"
      end
      return ret
    end
    
    def errno_enoent_inspect
      "ファイルアクセスに失敗しました。ファイルがありません。"
    end
    
    def type_error_inspect
      "「#{@method}」への引数のタイプ（型）が正しくありません。"
    end
    
    def zero_division_error_inspect
      "割る数が 0 での割り算はできません。"
    end
    
    def system_stack_error_inspect
      "システムスタックがあふれました。意図しない無限ループが生じている可能性があります。"
    end
    
    Eturem.eturem_class = self
  end
end

require "eturem"