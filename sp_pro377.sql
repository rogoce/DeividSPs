-- Detalle por Ramo Automovil(Canceladas) 
-- Creado    : 06/03/2013 - Autor: Roman Gordon
-- SIS v.2.0 - DEIVID, S.A.

drop procedure sp_pro377;
create procedure "informix".sp_pro377(a_periodo char(7),a_periodo2 char(7))
returning	char(03),
			char(50),
			char(20),
			char(7),
			dec(16,2),
			char(50),
			char(16),
			varchar(50);
begin
	define v_desc_ramo			char(50);
	define _no_documento		char(20);
	define _no_poliza			char(10);
	define _periodo				char(7);
	define _no_endoso			char(5);
	define _cod_ramo			char(3);
	define _cod_mov				char(3);
	define _tipo				char(1);
	define _prima_neta			dec(16,2);
	define v_reaseguro			dec(16,2);
	define _cod_contratante     char(10);
	DEFINE _codigo              char(16);
	define _n_cliente           char(50);
	define _cod_tipocan         char(3);
	define _n_grupo             varchar(50);
	define _cod_grupo           char(5);
	
	create temp table tmp_cancela
			(no_documento		char(20),
			cod_ramo			char(03),
			prima_neta			dec(16,2),
			no_poliza			char(10),
			no_endoso			char(5),
			periodo				char(7),
			cod_contratante     char(10),
			cod_tipocan         char(3),
			seleccionado		smallint default 1);
--   CREATE INDEX i_cancela5 ON tmp_cancela(cod_contratante);

	let v_desc_ramo      = null;
	let _n_cliente       = null;

	set isolation to dirty read;

	select cod_endomov
	  into _cod_mov
	  from endtimov
	 where tipo_mov = 2;

	foreach
		select e.no_documento,
			   e.cod_ramo,
			   e.cod_contratante,
			   x.no_poliza,
			   x.no_endoso,
			   x.prima_neta,
			   x.cod_tipocan
		  into _no_documento,
			   _cod_ramo,
			   _cod_contratante,
			   _no_poliza,
			   _no_endoso,
			   _prima_neta,
			   _cod_tipocan
	     from emipomae e, endedmae x
	    where e.cod_compania = '001'
	      and e.no_poliza    = x.no_poliza
	      and x.periodo     >= a_periodo
		  and x.periodo     <= a_periodo2
	      and x.actualizado  = 1
	      and x.cod_endomov  = _cod_mov
		  and x.cod_tipocan  in('001','010','013')
	    order by e.cod_ramo

       insert into tmp_cancela
       values(  _no_documento,
				_cod_ramo,
				_prima_neta,
				_no_poliza,
				_no_endoso,
				_prima_neta,
				_cod_contratante,
				_cod_tipocan,
				1);
    end foreach
	
	foreach
		select no_documento,
			   cod_ramo,
			   no_poliza,
			   no_endoso,
			   prima_neta,
			   cod_contratante,
			   cod_tipocan
		  into _no_documento,
			   _cod_ramo,
			   _no_poliza,
			   _no_endoso,
			   _prima_neta,
			   _cod_contratante,
			   _cod_tipocan
		  from tmp_cancela
		 where seleccionado = 1
		 order by cod_ramo

	   --ramo
       select nombre
         into v_desc_ramo
         from prdramo
        where cod_ramo = _cod_ramo;

		select periodo
	     into _periodo
		 from endedmae
		where no_poliza = _no_poliza
		  and no_endoso = _no_endoso;

		select cod_grupo
	     into _cod_grupo
		 from emipomae
		where no_poliza = _no_poliza;

		select nombre
	     into _n_grupo
		 from cligrupo
		where cod_grupo = _cod_grupo;
        

        select nombre
		  into _n_cliente
		  from cliclien
		 where cod_cliente = _cod_contratante;

		if _cod_tipocan = '001' then
			let _codigo = 'FALTA DE PAGO';
		elif _cod_tipocan = '010' then
			let _codigo = 'SALDO PENDIENTE';
		else
			let _codigo = 'INCOBRABLE';
		end if

       return _cod_ramo,
       		  v_desc_ramo,
              _no_documento,
              _periodo,
			  _prima_neta,
			  _n_cliente,
			  _codigo,
			  _n_grupo
              with resume;

    end foreach
	drop table tmp_cancela;
end
end procedure;
