-- Proceso que verifica excepciones y equivalencias en la carga de emisiones electronicas.
-- Creado    : 08/08/2012 - Autor: Roman Gordon
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_refresca_txt;

create procedure "informix".sp_refresca_txt(a_fecha_hasta date)
returning integer,
		  smallint,
		  char(30),
          char(100);

define _error_desc			char(100);
define _campo				char(30);
define _no_documento		char(21);
define _no_poliza			char(10);
define _cod_acreedor		char(10);
define _cod_producto		char(10);
define _cod_subramo			char(10);
define _cod_perpago			char(10);
define _cod_color			char(10);
define _cod_ramo			char(10);
define _deducible			dec(16,2);
define _limite1   			dec(16,2);
define _limite2		   		dec(16,2);
define _prima		   		dec(16,2);
define _error_isam			smallint;
define _cnt_existe			smallint;
define _tipo_cober			smallint;
define _return				smallint;
define _existe				smallint;
define _error				smallint;
define _renglon				integer;
define _vigencia_inic		date;
define _vig_inic			date;


--set debug file to "sp_refresca_txt.trc";
--trace on;

set isolation to dirty read;

begin
on exception set _error,_error_isam,_error_desc
	return _error,_error_isam,"Error al verificar las Equivalencias y Excepciones de la carga. ", _error_desc;
end exception

let _error = 0;

foreach
	select no_poliza,no_documento,
		   vigencia_inic
	  into _no_poliza,_no_documento,
		   _vigencia_inic
	  from emipomae
	 where no_poliza in ('768094') --',
	-- where no_documento = '0203-00155-01';}
	
	{select no_documento,
		   vigencia_inic
	  into _no_documento,
		   _vigencia_inic
	  from emipomae 
	 where no_documento in ('0204-02182-56','0212-90793-47','0212-90795-47'){(select no_documento
							  from emirenduc
							 where no_documento in ('0204-90086-47','0206-90010-47','0206-90013-47','0207-10018-47','0207-10022-47','0207-10029-47','0208-10003-47','0209-90016-47','0210-10040-47',
													'0210-10041-47','0210-10044-47','0210-10048-47','0210-10051-47','0210-90047-47','0210-90050-47','0210-90052-47','0210-90055-47','0210-90061-47',
													'0210-90066-47','0210-90072-47','0210-90073-47','0210-90076-47','0210-90320-47','0211-00423-01','0211-10008-47','0211-10010-47','0211-10022-47',
													'0211-10215-47','0211-10226-47','0211-10227-47','0211-10233-47','0211-10234-47','0211-10236-47','0211-10243-47','0211-10244-47','0211-10248-47',
													'0211-10250-47','0211-10251-47','0211-10252-47','0211-10253-47','0211-10254-47','0211-10255-47','0211-10256-47','0211-10257-47','0211-10260-47',
													'0211-10261-47','0211-10262-47','0211-10263-47','0211-10269-47','0211-10272-47','0211-10274-47','0211-10277-47','0211-10279-47','0211-20009-47',
													'0211-20010-47','0211-20012-47','0211-20014-47','0211-20015-47','0211-20016-47','0211-20017-47','0211-20019-47','0211-20023-47','0211-20025-47',
													'0211-20027-47','0211-20029-47','0211-20030-47','0211-20032-47','0211-20133-47','0211-30004-47','0211-30005-47','0211-90403-47','0211-90410-47',
													'0211-90436-47','0211-90437-47','0211-90438-47','0211-90441-47','0211-90442-47','0211-90443-47','0211-90444-47','0211-90446-47','0211-90449-47',
													'0211-90450-47','0211-90451-47','0211-90452-47','0211-90453-47','0211-90454-47','0211-90455-47','0211-90456-47','0211-90459-47','0211-90462-47',
													'0211-90463-47','0211-90464-47','0211-90466-47','0211-90467-47','0211-90468-47','0211-90469-47','0211-90470-47','0211-90471-47','0211-90472-47',
													'0211-90475-47','0211-90476-47','0211-90477-47','0211-90478-47','0211-90479-47','0211-90481-47','0211-90485-47','0211-90505-47','0212-10343-47',
													'0212-15382-47','0212-15383-47','0212-15384-47','0212-20135-47','0212-20136-47','0212-90761-47','0212-90762-47','0212-90763-47','0212-90764-47',
													'0212-90765-47','0212-90766-47','0212-90767-47','0212-90768-47','0210-00054-02','0204-00212-23','0204-00220-23','0204-00241-23','0204-90109-47',
													'0204-90111-47','0204-90122-47','0209-90018-47','0210-90059-47','0211-10270-47','0211-10273-47','0204-02130-56','0205-20147-56','0205-20217-56',
													'0205-20242-56','0205-20248-56','0205-20253-56','0206-20113-56','0206-20128-56','0206-20134-56','0206-20145-56','0206-20151-56','0207-10023-47',
													'0210-90051-47')
							   and caida_objetos_prima is null)	}
	--let _vig_ini_format = ;
	
	if _vigencia_inic not between '01/01/2014' and '31/01/2014' then
		continue foreach;
	end if	   
	
	--call sp_sis21(_no_documento) returning _no_poliza;
	
	--let _no_poliza = '718209';
	select vigencia_inic
	  into _vig_inic
	  from emipomae
	 where no_poliza = _no_poliza;
	
	if year(_vig_inic) <> 2014 then
		continue foreach;
	end if
	
	call sp_pro371(_no_poliza) returning _error,_error_desc;
	
	if _error <> 0 then
		return _error,-1,_error_desc,'';
	end if	
	
	return 0,0,_no_documento,'' with resume;
end foreach
end 
end procedure	 