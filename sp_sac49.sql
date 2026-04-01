DROP PROCEDURE sp_sac49;

CREATE PROCEDURE sp_sac49(a_db CHAR(18), a_notrx integer) 
RETURNING integer,
            char(50);

define _error		integer;
define _error_isam	integer;
define _error_desc	char(50);

begin 
on exception set _error, _error_isam, _error_desc
	return _error, _error_desc;
end exception

if a_db = "sac" then

	select *
	  from sac:cgltrx1
	 WHERE trx1_notrx  = a_notrx
	  into temp tmp_cgltrx1;

	select *
	  from sac:cgltrx2
	 WHERE trx2_notrx  = a_notrx
	  into temp tmp_cgltrx2;

	select *
	  from sac:cgltrx3
	 WHERE trx3_notrx  = a_notrx
	  into temp tmp_cgltrx3;

	select *
	  from sac:cglconcepto
	  into temp tmp_cglconcepto;

	select *
	  from sac:cglcuentas
	  into temp tmp_cglcuentas;

	select *
	  from sac:cglterceros
	  into temp tmp_cglterceros;

elif a_db = "sac001" then

	select *
	  from sac001:cgltrx1
	 WHERE trx1_notrx  = a_notrx
	  into temp tmp_cgltrx1;

	select *
	  from sac001:cgltrx2
	 WHERE trx2_notrx  = a_notrx
	  into temp tmp_cgltrx2;

	select *
	  from sac001:cgltrx3
	 WHERE trx3_notrx  = a_notrx
	  into temp tmp_cgltrx3;

	select *
	  from sac001:cglconcepto
	  into temp tmp_cglconcepto;

	select *
	  from sac001:cglcuentas
	  into temp tmp_cglcuentas;

	select *
	  from sac001:cglterceros
	  into temp tmp_cglterceros;

elif a_db = "sac002" then

	select *
	  from sac002:cgltrx1
	 WHERE trx1_notrx  = a_notrx
	  into temp tmp_cgltrx1;

	select *
	  from sac002:cgltrx2
	 WHERE trx2_notrx  = a_notrx
	  into temp tmp_cgltrx2;

	select *
	  from sac002:cgltrx3
	 WHERE trx3_notrx  = a_notrx
	  into temp tmp_cgltrx3;

	select *
	  from sac002:cglconcepto
	  into temp tmp_cglconcepto;

	select *
	  from sac002:cglcuentas
	  into temp tmp_cglcuentas;

	select *
	  from sac002:cglterceros
	  into temp tmp_cglterceros;

elif a_db = "sac003" then

	select *
	  from sac003:cgltrx1
	 WHERE trx1_notrx  = a_notrx
	  into temp tmp_cgltrx1;

	select *
	  from sac003:cgltrx2
	 WHERE trx2_notrx  = a_notrx
	  into temp tmp_cgltrx2;

	select *
	  from sac003:cgltrx3
	 WHERE trx3_notrx  = a_notrx
	  into temp tmp_cgltrx3;

	select *
	  from sac003:cglconcepto
	  into temp tmp_cglconcepto;

	select *
	  from sac003:cglcuentas
	  into temp tmp_cglcuentas;

	select *
	  from sac003:cglterceros
	  into temp tmp_cglterceros;

elif a_db = "sac004" then

	select *
	  from sac004:cgltrx1
	 WHERE trx1_notrx  = a_notrx
	  into temp tmp_cgltrx1;

	select *
	  from sac004:cgltrx2
	 WHERE trx2_notrx  = a_notrx
	  into temp tmp_cgltrx2;

	select *
	  from sac004:cgltrx3
	 WHERE trx3_notrx  = a_notrx
	  into temp tmp_cgltrx3;

	select *
	  from sac004:cglconcepto
	  into temp tmp_cglconcepto;

	select *
	  from sac004:cglcuentas
	  into temp tmp_cglcuentas;

	select *
	  from sac004:cglterceros
	  into temp tmp_cglterceros;

elif a_db = "sac005" then

	select *
	  from sac005:cgltrx1
	 WHERE trx1_notrx  = a_notrx
	  into temp tmp_cgltrx1;

	select *
	  from sac005:cgltrx2
	 WHERE trx2_notrx  = a_notrx
	  into temp tmp_cgltrx2;

	select *
	  from sac005:cgltrx3
	 WHERE trx3_notrx  = a_notrx
	  into temp tmp_cgltrx3;

	select *
	  from sac005:cglconcepto
	  into temp tmp_cglconcepto;

	select *
	  from sac005:cglcuentas
	  into temp tmp_cglcuentas;

	select *
	  from sac005:cglterceros
	  into temp tmp_cglterceros;

elif a_db = "sac006" then

	select *
	  from sac006:cgltrx1
	 WHERE trx1_notrx  = a_notrx
	  into temp tmp_cgltrx1;

	select *
	  from sac006:cgltrx2
	 WHERE trx2_notrx  = a_notrx
	  into temp tmp_cgltrx2;

	select *
	  from sac006:cgltrx3
	 WHERE trx3_notrx  = a_notrx
	  into temp tmp_cgltrx3;

	select *
	  from sac006:cglconcepto
	  into temp tmp_cglconcepto;

	select *
	  from sac006:cglcuentas
	  into temp tmp_cglcuentas;

	select *
	  from sac006:cglterceros
	  into temp tmp_cglterceros;

elif a_db = "sac007" then

	select *
	  from sac007:cgltrx1
	 WHERE trx1_notrx  = a_notrx
	  into temp tmp_cgltrx1;

	select *
	  from sac007:cgltrx2
	 WHERE trx2_notrx  = a_notrx
	  into temp tmp_cgltrx2;

	select *
	  from sac007:cgltrx3
	 WHERE trx3_notrx  = a_notrx
	  into temp tmp_cgltrx3;

	select *
	  from sac007:cglconcepto
	  into temp tmp_cglconcepto;

	select *
	  from sac007:cglcuentas
	  into temp tmp_cglcuentas;

	select *
	  from sac007:cglterceros
	  into temp tmp_cglterceros;

elif a_db = "sac008" then

	select *
	  from sac008:cgltrx1
	 WHERE trx1_notrx  = a_notrx
	  into temp tmp_cgltrx1;

	select *
	  from sac008:cgltrx2
	 WHERE trx2_notrx  = a_notrx
	  into temp tmp_cgltrx2;

	select *
	  from sac008:cgltrx3
	 WHERE trx3_notrx  = a_notrx
	  into temp tmp_cgltrx3;

	select *
	  from sac008:cglconcepto
	  into temp tmp_cglconcepto;

	select *
	  from sac008:cglcuentas
	  into temp tmp_cglcuentas;

	select *
	  from sac008:cglterceros
	  into temp tmp_cglterceros;

end if

end 

return 0, "Actualizacion Exitosa";

end procedure 