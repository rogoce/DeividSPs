
drop procedure sp_cob352;
create procedure "informix".sp_cob352()
returning	char(20)	as No_documento,		--_no_documento,
			char(10)	as Poliza,				--_no_poliza,
			integer		as No_Cambio,			--_no_cambio,
			integer		as Ult_Cambio,			--_ult_cambio,
			char(3)		as Cod_Formapag,		--_cod_formapag,
			char(3)		as Tipo_Electronico;	--_tipo_elect;

define _error_desc		varchar(100);
define _no_documento	char(20);
define _no_poliza		char(10);
define _cod_formapag	char(3);
define _tipo_elect		char(3);
define _tipo_forma		smallint;
define _error_isam		integer;
define _ult_cambio		integer;
define _no_cambio		integer;
define _error			integer;
define _cnt             smallint;

set isolation to dirty read;

--set debug file to "sp_cob352.trc";
--trace on;

begin
on exception set _error,_error_isam,_error_desc
 	return _error_desc,'',_error,0,'','';
end exception

create temp table tmp_cobcampl(
no_documento	char(20),
no_poliza       char(10),
no_cambio		integer,
tipo_elect		char(3)) with no log;

foreach
	select c.no_documento,
		   c.no_poliza,
		   min(c.no_cambio)
	  into _no_documento,
		   _no_poliza,
		   _no_cambio
	  from cobtacre t, cobcampl c
	 where t.no_documento = c.no_documento
	   and c.fecha_cambio >= '01/01/2015'
	 group by c.no_documento,c.no_poliza
	 order by c.no_documento

	insert into tmp_cobcampl(
			no_documento,
			no_poliza,
			no_cambio,
			tipo_elect)
	values(	_no_documento,
			_no_poliza,
			_no_cambio,
			'TCR');
end foreach

foreach
	select c.no_documento,
		   c.no_poliza,
		   min(c.no_cambio)
	  into _no_documento,
		   _no_poliza,
		   _no_cambio
	  from cobcutas t, cobcampl c
	 where t.no_documento = c.no_documento
	   and c.fecha_cambio >= '01/01/2015'
	 group by c.no_documento,c.no_poliza
	 order by c.no_documento

	insert into tmp_cobcampl(
			no_documento,
			no_poliza,
			no_cambio,
			tipo_elect)
	values(	_no_documento,
			_no_poliza,
			_no_cambio,
			'ACH');
end foreach

foreach
	select no_documento,
		   no_poliza,
		   no_cambio,
		   tipo_elect
	  into _no_documento,
		   _no_poliza,
		   _no_cambio,
		   _tipo_elect
	  from tmp_cobcampl
	 order by no_documento

	select max(no_cambio)
	  into _ult_cambio
	  from cobcampl
	 where no_documento = _no_documento
	   and fecha_cambio < '01/01/2015';

	if _ult_cambio is null then
		let _ult_cambio = 0;
	end if

	if _ult_cambio = 0 then
		select cod_formapag
		  into _cod_formapag
		  from endedhis
		 where no_poliza = _no_poliza
		   and no_endoso = '00000';
	else
		select cod_formapag
		  into _cod_formapag
		  from cobcampl
		 where no_documento = _no_documento
		   and no_cambio = _ult_cambio;
	end if

	select tipo_forma
	  into _tipo_forma
	  from cobforpa
	 where cod_formapag = _cod_formapag;

	if _tipo_forma in (2,4) then
		continue foreach;
	end if
	
	select count(*)
	  into _cnt
  	  from cobcampl2
	 where no_documento = _no_documento;
	 
    if _cnt > 0 then
	else
	
		insert into cobcampl2
		select *,0 from cobcampl
		 where no_documento = _no_documento
		   and no_cambio    = _no_cambio;

		update cobcampl2
		   set cod_formapag = _cod_formapag
		 where no_documento = _no_documento
		   and no_cambio    = _no_cambio;
	end if   
	  
	return	_no_documento,
			_no_poliza,
			_no_cambio,
			_ult_cambio,
			_cod_formapag,
			_tipo_elect	with resume;
end foreach

drop table tmp_cobcampl;
end
end procedure;