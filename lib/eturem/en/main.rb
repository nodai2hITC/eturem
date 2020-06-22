require "eturem/base"
Dir[File.expand_path("..", __FILE__) + "/*.rb"].each do |path|
  require path unless path == File.expand_path(__FILE__)
end

module Eturem
  def self._extend_exception(exception)
    ext = case exception
#          when NoMemoryError then NoMemoryErrorExt
#          when LoadError then LoadErrorExt
#          when NotImplementedError then NotImplementedErrorExt
          when SyntaxError then SyntaxErrorExt
#          when ScriptError then ScriptErrorExt
#          when SecurityError then SecurityErrorExt
#          when Interrupt then InterruptExt
#          when SignalException then SignalExceptionExt
#          when UncaughtThrowError then UncaughtThrowErrorExt
          when ArgumentError then ArgumentErrorExt
#          when Encoding::CompatibilityError then Encoding_CompatibilityErrorExt
#          when Encoding::ConverterNotFoundError then Encoding_ConverterNotFoundErrorExt
#          when Encoding::InvalidByteSequenceError then Encoding_InvalidByteSequenceErrorExt
#          when Encoding::UndefinedConversionError then Encoding_UndefinedConversionErrorExt
#          when EncodingError then EncodingErrorExt
#          when FiberError then FiberErrorExt
#          when EOFError then EOFErrorExt
#          when IOError then IOErrorExt
#          when KeyError then KeyErrorExt
#          when ClosedQueueError then ClosedQueueErrorExt
#          when StopIteration then StopIterationExt
#          when IndexError then IndexErrorExt
#          when LocalJumpError then LocalJumpErrorExt
#          when Math::DomainError then Math_DomainErrorExt
#          when NoMethodError then NoMethodErrorExt
          when NameError then NameErrorExt
#          when FloatDomainError then FloatDomainErrorExt
#          when RangeError then RangeErrorExt
#          when RegexpError then RegexpErrorExt
#          when RuntimeError then RuntimeErrorExt
#          when Errno::E2BIG then Errno_E2BIGExt
#          when Errno::EACCES then Errno_EACCESExt
#          when Errno::EADDRINUSE then Errno_EADDRINUSEExt
#          when Errno::EADDRNOTAVAIL then Errno_EADDRNOTAVAILExt
#          when Errno::EADV then Errno_EADVExt
#          when Errno::EAFNOSUPPORT then Errno_EAFNOSUPPORTExt
#          when Errno::EAGAIN then Errno_EAGAINExt
#          when Errno::EALREADY then Errno_EALREADYExt
#          when Errno::EAUTH then Errno_EAUTHExt
#          when Errno::EBADE then Errno_EBADEExt
#          when Errno::EBADF then Errno_EBADFExt
#          when Errno::EBADFD then Errno_EBADFDExt
#          when Errno::EBADMSG then Errno_EBADMSGExt
#          when Errno::EBADR then Errno_EBADRExt
#          when Errno::EBADRPC then Errno_EBADRPCExt
#          when Errno::EBADRQC then Errno_EBADRQCExt
#          when Errno::EBADSLT then Errno_EBADSLTExt
#          when Errno::EBFONT then Errno_EBFONTExt
#          when Errno::EBUSY then Errno_EBUSYExt
#          when Errno::ECANCELED then Errno_ECANCELEDExt
#          when Errno::ECAPMODE then Errno_ECAPMODEExt
#          when Errno::ECHILD then Errno_ECHILDExt
#          when Errno::ECHRNG then Errno_ECHRNGExt
#          when Errno::ECOMM then Errno_ECOMMExt
#          when Errno::ECONNABORTED then Errno_ECONNABORTEDExt
#          when Errno::ECONNREFUSED then Errno_ECONNREFUSEDExt
#          when Errno::ECONNRESET then Errno_ECONNRESETExt
#          when Errno::EDEADLK then Errno_EDEADLKExt
#          when Errno::EDEADLOCK then Errno_EDEADLOCKExt
#          when Errno::EDESTADDRREQ then Errno_EDESTADDRREQExt
#          when Errno::EDOM then Errno_EDOMExt
#          when Errno::EDOOFUS then Errno_EDOOFUSExt
#          when Errno::EDOTDOT then Errno_EDOTDOTExt
#          when Errno::EDQUOT then Errno_EDQUOTExt
#          when Errno::EEXIST then Errno_EEXISTExt
#          when Errno::EFAULT then Errno_EFAULTExt
#          when Errno::EFBIG then Errno_EFBIGExt
#          when Errno::EFTYPE then Errno_EFTYPEExt
#          when Errno::EHOSTDOWN then Errno_EHOSTDOWNExt
#          when Errno::EHOSTUNREACH then Errno_EHOSTUNREACHExt
#          when Errno::EHWPOISON then Errno_EHWPOISONExt
#          when Errno::EIDRM then Errno_EIDRMExt
#          when Errno::EILSEQ then Errno_EILSEQExt
#          when Errno::EINPROGRESS then Errno_EINPROGRESSExt
#          when Errno::EINTR then Errno_EINTRExt
#          when Errno::EINVAL then Errno_EINVALExt
#          when Errno::EIO then Errno_EIOExt
#          when Errno::EIPSEC then Errno_EIPSECExt
#          when Errno::EISCONN then Errno_EISCONNExt
#          when Errno::EISDIR then Errno_EISDIRExt
#          when Errno::EISNAM then Errno_EISNAMExt
#          when Errno::EKEYEXPIRED then Errno_EKEYEXPIREDExt
#          when Errno::EKEYREJECTED then Errno_EKEYREJECTEDExt
#          when Errno::EKEYREVOKED then Errno_EKEYREVOKEDExt
#          when Errno::EL2HLT then Errno_EL2HLTExt
#          when Errno::EL2NSYNC then Errno_EL2NSYNCExt
#          when Errno::EL3HLT then Errno_EL3HLTExt
#          when Errno::EL3RST then Errno_EL3RSTExt
#          when Errno::ELIBACC then Errno_ELIBACCExt
#          when Errno::ELIBBAD then Errno_ELIBBADExt
#          when Errno::ELIBEXEC then Errno_ELIBEXECExt
#          when Errno::ELIBMAX then Errno_ELIBMAXExt
#          when Errno::ELIBSCN then Errno_ELIBSCNExt
#          when Errno::ELNRNG then Errno_ELNRNGExt
#          when Errno::ELOOP then Errno_ELOOPExt
#          when Errno::EMEDIUMTYPE then Errno_EMEDIUMTYPEExt
#          when Errno::EMFILE then Errno_EMFILEExt
#          when Errno::EMLINK then Errno_EMLINKExt
#          when Errno::EMSGSIZE then Errno_EMSGSIZEExt
#          when Errno::EMULTIHOP then Errno_EMULTIHOPExt
#          when Errno::ENAMETOOLONG then Errno_ENAMETOOLONGExt
#          when Errno::ENAVAIL then Errno_ENAVAILExt
#          when Errno::ENEEDAUTH then Errno_ENEEDAUTHExt
#          when Errno::ENETDOWN then Errno_ENETDOWNExt
#          when Errno::ENETRESET then Errno_ENETRESETExt
#          when Errno::ENETUNREACH then Errno_ENETUNREACHExt
#          when Errno::ENFILE then Errno_ENFILEExt
#          when Errno::ENOANO then Errno_ENOANOExt
#          when Errno::ENOATTR then Errno_ENOATTRExt
#          when Errno::ENOBUFS then Errno_ENOBUFSExt
#          when Errno::ENOCSI then Errno_ENOCSIExt
#          when Errno::ENODATA then Errno_ENODATAExt
#          when Errno::ENODEV then Errno_ENODEVExt
#          when Errno::ENOENT then Errno_ENOENTExt
#          when Errno::ENOEXEC then Errno_ENOEXECExt
#          when Errno::ENOKEY then Errno_ENOKEYExt
#          when Errno::ENOLCK then Errno_ENOLCKExt
#          when Errno::ENOLINK then Errno_ENOLINKExt
#          when Errno::ENOMEDIUM then Errno_ENOMEDIUMExt
#          when Errno::ENOMEM then Errno_ENOMEMExt
#          when Errno::ENOMSG then Errno_ENOMSGExt
#          when Errno::ENONET then Errno_ENONETExt
#          when Errno::ENOPKG then Errno_ENOPKGExt
#          when Errno::ENOPROTOOPT then Errno_ENOPROTOOPTExt
#          when Errno::ENOSPC then Errno_ENOSPCExt
#          when Errno::ENOSR then Errno_ENOSRExt
#          when Errno::ENOSTR then Errno_ENOSTRExt
#          when Errno::ENOSYS then Errno_ENOSYSExt
#          when Errno::ENOTBLK then Errno_ENOTBLKExt
#          when Errno::ENOTCAPABLE then Errno_ENOTCAPABLEExt
#          when Errno::ENOTCONN then Errno_ENOTCONNExt
#          when Errno::ENOTDIR then Errno_ENOTDIRExt
#          when Errno::ENOTEMPTY then Errno_ENOTEMPTYExt
#          when Errno::ENOTNAM then Errno_ENOTNAMExt
#          when Errno::ENOTRECOVERABLE then Errno_ENOTRECOVERABLEExt
#          when Errno::ENOTSOCK then Errno_ENOTSOCKExt
#          when Errno::ENOTSUP then Errno_ENOTSUPExt
#          when Errno::ENOTTY then Errno_ENOTTYExt
#          when Errno::ENOTUNIQ then Errno_ENOTUNIQExt
#          when Errno::ENXIO then Errno_ENXIOExt
#          when Errno::EOPNOTSUPP then Errno_EOPNOTSUPPExt
#          when Errno::EOVERFLOW then Errno_EOVERFLOWExt
#          when Errno::EOWNERDEAD then Errno_EOWNERDEADExt
#          when Errno::EPERM then Errno_EPERMExt
#          when Errno::EPFNOSUPPORT then Errno_EPFNOSUPPORTExt
#          when Errno::EPIPE then Errno_EPIPEExt
#          when Errno::EPROCLIM then Errno_EPROCLIMExt
#          when Errno::EPROCUNAVAIL then Errno_EPROCUNAVAILExt
#          when Errno::EPROGMISMATCH then Errno_EPROGMISMATCHExt
#          when Errno::EPROGUNAVAIL then Errno_EPROGUNAVAILExt
#          when Errno::EPROTO then Errno_EPROTOExt
#          when Errno::EPROTONOSUPPORT then Errno_EPROTONOSUPPORTExt
#          when Errno::EPROTOTYPE then Errno_EPROTOTYPEExt
#          when Errno::ERANGE then Errno_ERANGEExt
#          when Errno::EREMCHG then Errno_EREMCHGExt
#          when Errno::EREMOTE then Errno_EREMOTEExt
#          when Errno::EREMOTEIO then Errno_EREMOTEIOExt
#          when Errno::ERESTART then Errno_ERESTARTExt
#          when Errno::ERFKILL then Errno_ERFKILLExt
#          when Errno::EROFS then Errno_EROFSExt
#          when Errno::ERPCMISMATCH then Errno_ERPCMISMATCHExt
#          when Errno::ESHUTDOWN then Errno_ESHUTDOWNExt
#          when Errno::ESOCKTNOSUPPORT then Errno_ESOCKTNOSUPPORTExt
#          when Errno::ESPIPE then Errno_ESPIPEExt
#          when Errno::ESRCH then Errno_ESRCHExt
#          when Errno::ESRMNT then Errno_ESRMNTExt
#          when Errno::ESTALE then Errno_ESTALEExt
#          when Errno::ESTRPIPE then Errno_ESTRPIPEExt
#          when Errno::ETIME then Errno_ETIMEExt
#          when Errno::ETIMEDOUT then Errno_ETIMEDOUTExt
#          when Errno::ETOOMANYREFS then Errno_ETOOMANYREFSExt
#          when Errno::ETXTBSY then Errno_ETXTBSYExt
#          when Errno::EUCLEAN then Errno_EUCLEANExt
#          when Errno::EUNATCH then Errno_EUNATCHExt
#          when Errno::EUSERS then Errno_EUSERSExt
#          when Errno::EWOULDBLOCK then Errno_EWOULDBLOCKExt
#          when Errno::EXDEV then Errno_EXDEVExt
#          when Errno::EXFULL then Errno_EXFULLExt
#          when Errno::EXXX then Errno_EXXXExt
#          when Errno::NOERROR then Errno_NOERRORExt
#          when SystemCallError then SystemCallErrorExt
#          when ThreadError then ThreadErrorExt
#          when TypeError then TypeErrorExt
#          when ZeroDivisionError then ZeroDivisionErrorExt
#          when StandardError then StandardErrorExt
#          when SystemStackError then SystemStackErrorExt
          end
    return ext if ext
#    ext = case exception.class.to_s
#          when "FrozenError" then FrozenErrorExt
#          when "GemOriginalError" then GemOriginalErrorExt
#          end
    return ext
  end

  module ExceptionExt
    def eturem_location_to_s(location)
      super
    end

    def eturem_traceback(order = :bottom)
      super
    end
  end
end
