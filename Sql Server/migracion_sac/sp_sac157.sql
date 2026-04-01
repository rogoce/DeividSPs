-- Consulta de Movimientos de Cuentas Sac x Cheques
-- Creado    : 29/12/2008 - Autor: Henry Girón
-- SIS v.2.0 - DEIVID, S.A.	
-- execute procedure sp_sac157( '121020402','COB12091','18/12/2009','348552')

drop procedure sp_sac157;
create procedure sp_sac157(a_cuenta char(12), a_comp char(15), a_fecha date, a_requis char(10)) 
returning	char(12),		--cuenta 
			char(15), 		--comprobante 
			date,			--fecha
			char(10),		-- requis
			smallint,		-- renglon
			dec(15,2),		-- debito
			dec(15,2),		-- credito
			dec(15,2),		-- neto
			char(10),		-- cheque
			char(50);  	    -- tipo de movimiento

define v_nombre	    	char(50);
define i_comprobante	char(15);
define i_cuenta			char(12);
define i_origen			char(12);
define v_no_recibo      char(10);
define d_requis			char(10);
define v_tipo_mov		char(1);
define i_credito		dec(15,2);
define d_credito		dec(15,2);
define i_debito			dec(15,2);
define d_debito			dec(15,2);
define i_neto           dec(15,2);
define d_renglon		smallint;
define i_notrx			integer;
define i_fechatrx		date;

set isolation to dirty read;


create temp table tmp_requis(
		cuenta			char(12),
		comprobante		char(15),
		fechatrx		date,
		notrx			integer,
		debito			dec(15,2)   default 0,
		credito			dec(15,2)   default 0,
		neto            dec(15,2)   default 0,
		origen			char(3),
		requis          char(10),
		renglon			smallint
		) with no log; 	

--  set debug file to "sp_sac157.trc";	
--  trace on;

foreach
	select res_notrx,
		   res_origen,
		   res_debito,
		   res_credito
	  into i_notrx,
	  	   i_origen,
	  	   i_debito,
	  	   i_credito
	  from cglresumen
	 where res_cuenta		= a_cuenta
	   and res_comprobante	= a_comp
	   and res_fechatrx		= a_fecha
	 order by res_comprobante,res_fechatrx,res_notrx,res_noregistro,res_origen

	if 	i_origen in ('CHE','PLA') then

		foreach
			select no_requis,
				   renglon,
				   debito,
				   credito 
			  into d_requis,
			  	   d_renglon,
			  	   d_debito,
			  	   d_credito
			  from deivid:chqchcta
			 where sac_notrx	= i_notrx
			   and cuenta		= a_cuenta
			   and no_requis	= a_requis
			 order by no_requis,renglon

			if d_debito is null then
				let d_debito = 0; 
			end if
			if d_credito is null then
				let d_credito = 0; 
			end if

			let i_neto = d_debito - d_credito ;

			insert into tmp_requis (
				cuenta,
				comprobante,
				fechatrx,
				notrx,
				debito,
				credito,
				neto,
				origen,
				requis,
				renglon )
			values (
				a_cuenta,
				a_comp,
				a_fecha,
				i_notrx,
				d_debito,
				d_credito,
				i_neto,
				i_origen,
				d_requis,
				d_renglon
				);
		end foreach;
	end if   
end foreach;

foreach	
	select requis,
		   renglon,
		   sum(debito),
		   sum(credito),
		   sum(neto)
	  into d_requis,
	  	   d_renglon,
	  	   d_debito,
	  	   d_credito,
	  	   i_neto
	  from tmp_requis
	 where cuenta = 	a_cuenta
	   and comprobante = a_comp
	   and fechatrx  = a_fecha
	   and   requis = a_requis
	 group by requis,renglon
	 order by requis,renglon

	select no_cheque,
		   tipo_requis
	  into v_no_recibo,
	  	   v_tipo_mov 		
	  from deivid:chqchmae
	 where no_requis = d_requis ;
--	   and renglon   = d_renglon ;

	if v_tipo_mov = 'A' then
		let v_nombre = "ACH";
	elif v_tipo_mov = 'C' then
		let v_nombre = "Cheque";
	end if

	return a_cuenta,
		   a_comp,
		   a_fecha,
		   d_requis,
		   d_renglon,
		   d_debito,
		   d_credito,
		   i_neto,
		   v_no_recibo,
		   v_nombre
		   with resume;
end foreach;
drop table tmp_requis;
end procedure					 				  				  			 