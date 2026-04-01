-- Verificar el campo reempalza poliza para los ramos de automovil y soda que tengan una unidad
-- Creado    : 06/02/2020 - Autor: Federico Coronado
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_emi02;
create procedure "informix".sp_emi02(a_no_poliza char(10))
returning integer,
varchar(20);

define _cod_ramo 		 char(3);
define _cnt_unidad		 smallint;
define _no_motor         varchar(30);
define _cod_grupo        varchar(5);
define _no_unidad        varchar(5);
define _no_documento	 char(20);
define _re_poliza 		 char(20); 
define _cnt_rnodoc       smallint;
define _estado_poliza    smallint;
define _no_p             char(10);

set isolation to dirty read;
	--set debug file to "sp_emi02bk.trc";
	--trace on;
 let _no_documento = null;
 
 select cod_ramo,
		 cod_grupo,
	    reemplaza_poliza
   into _cod_ramo,
        _cod_grupo,
		_re_poliza
   from emipomae
  where no_poliza = a_no_poliza;
  
if _cod_grupo = '78042' then
	return 0,"";	
end if
 
 select count(*)
   into _cnt_unidad
   from emipouni
  where no_poliza =  a_no_poliza;

 if _cod_ramo in('002','020') and _cnt_unidad = 1 then
	 select no_unidad
	   into _no_unidad
	   from emipouni
	  where no_poliza =  a_no_poliza;
	 
	 select no_motor
	   into _no_motor
	   from emiauto 
	  where no_poliza = a_no_poliza 
	    and no_unidad = _no_unidad;
	
	foreach	
		select no_documento
		  into _no_documento
		  from endmoaut a inner join endedmae b on a.no_poliza = b.no_poliza
		 where no_motor 		= _no_motor
		   and b.actualizado    = 1
		   and b.cod_endomov 	= '002' 	-- Cancelación de la póliza
		   and b.cod_tipocan  	= '009'	    -- Para ser reemplazada
		   and year((today - 5 UNITS YEAR)) <= year(b.vigencia_final)
	  order by vigencia_inic desc
	  if  trim(_no_documento) = trim(_re_poliza) then
		exit foreach;
	  end if	
	end foreach
	
	if _no_documento is not null or trim(_no_documento) <> '' then
		if _re_poliza is null or trim(_re_poliza) = '' then
		
			let _no_p = sp_sis21(_no_documento);
			
			select estatus_poliza
			  into _estado_poliza
			  from emipomae
			 where no_poliza = _no_p
			   and actualizado = 1;
			   
			   if _estado_poliza = 2 then
					return 327, trim(_no_documento);
			   end if
		else
			select count(*)
			  into _cnt_rnodoc
			  from emipomae
			 where no_documento = trim(_re_poliza)
			   and actualizado = 1;
			 
				if _cnt_rnodoc = 0 or _cnt_rnodoc is null then
					return 327, trim(_no_documento);
				end if
				if  trim(_no_documento) <> trim(_re_poliza) then
					return 327, trim(_no_documento);
				end if
		end if
	end if
 end if
return 0,"";	
end procedure