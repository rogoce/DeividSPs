-- Procedure que arregla que cuadre cglresumen vs cglresumen1

-- Creado    : 13/09/2007 - Autor: Demetrio Hurtado Almanza

-- SIS v.2.0 - DEIVID, S.A.


drop procedure sp_sac69;

create procedure sp_sac69(a_noregistro integer)
returning integer,
          dec(16,2),
		  dec(16,2),
          char(50);

define _notrx			integer;
define _linea			integer;
define _tipo_resumen	char(2);
define _comprobante		char(20);
define _origen			char(3);

define _cod_auxiliar	char(5);
define _debito			dec(16,2);
define _credito			dec(16,2);

define _debito2			dec(16,2);
define _credito2		dec(16,2);

define _cuenta			char(25);
define _fecha			date;
define _tipo			smallint;
define _fuente			char(3);

define _cantidad		smallint;
define _cantidad_aux	smallint;

begin work;

let _linea = 0;

select res_tipo_resumen,
       res_comprobante,
	   res_origen,
	   res_cuenta,
	   res_fechatrx,
	   res_debito,
	   res_credito,
	   res_notrx
  into _tipo_resumen,
       _comprobante,
	   _origen,
	   _cuenta,
	   _fecha,
	   _debito2,
	   _credito2,
	   _notrx
  from cglresumen
 where res_noregistro = a_noregistro;  

let _tipo   = _comprobante[8,8];
let _fuente = _comprobante[1,3];

select count(*)
  into _cantidad
  from cglresumen1
 where res1_noregistro = a_noregistro;

if _cantidad = 1 then

	update cglresumen1
	   set res1_debito     = _debito2,
	       res1_credito    = _credito2
	 where res1_noregistro = a_noregistro;

elif _cantidad = 0 then


	select count(*)
	  into _cantidad_aux
	  from cglauxiliar
	 where aux_cuenta  = _cuenta
	   and aux_tercero = "99999";

	if _cantidad_aux = 0 then

		insert into cglauxiliar
		values(_cuenta, "99999", 0.00, 0.00, 0.00, 0.00, 0.00, 0.00, 0.00,	0.00, "", "", "");

	end if

	insert into cglresumen1 ( res1_noregistro,res1_linea,res1_tipo_resumen,res1_comprobante,res1_cuenta,res1_auxiliar,res1_debito,res1_credito,res1_origen )
	values (a_noregistro, 1, _tipo_resumen, _comprobante, _cuenta, "99999", _debito2, _credito2, _origen);

else

	if _fuente = "CHE" then

		if _cuenta = "2400101" or
		--   _cuenta = "2610101"  or
		   _cuenta = "26410"   then

			if _tipo = 1 then

				select sum(a.debito),
					   sum(a.credito)
				  into _debito,
					   _credito
				  from chqchmae q, chqchcta c, chqctaux a
				 where q.no_requis       = c.no_requis
				   and c.no_requis       = a.no_requis
				   and c.renglon         = a.renglon
				   and q.pagado          = 1
				   and q.fecha_impresion = _fecha
				   and c.cuenta          = _cuenta
				   and c.tipo            = _tipo;

				if _debito is null then 
					let _debito = 0.00;
				end if
				 
				if _credito is null then 
					let _credito = 0.00;
				end if

				if _debito2  <> _debito  then

					rollback work;
					return 1, _debito2, _debito, "Registros Debito NO Cuadran (1)";

				end if

				if _credito2 <> _credito then

					rollback work;
					return 1, _credito2, _credito, "Registros Credito NO Cuadran (1)";

				end if

				delete from cglresumen1
				 where res1_noregistro = a_noregistro;

				foreach
				 select a.cod_auxiliar,
				        a.debito,
						a.credito
				   into _cod_auxiliar,
				        _debito,
						_credito
				   from chqchmae q, chqchcta c, chqctaux a
				  where q.no_requis       = c.no_requis
				    and c.no_requis       = a.no_requis
				    and c.renglon         = a.renglon
				    and q.pagado          = 1
				    and q.fecha_impresion = _fecha
				    and c.cuenta          = _cuenta
				    and c.tipo            = _tipo

					let _linea = _linea + 1;

					insert into cglresumen1 ( res1_noregistro,res1_linea,res1_tipo_resumen,res1_comprobante,res1_cuenta,res1_auxiliar,res1_debito,res1_credito,res1_origen )
					values (a_noregistro, _linea, _tipo_resumen, _comprobante, _cuenta, _cod_auxiliar, _debito, _credito, _origen);

				end foreach

			else

				select sum(a.debito),
					   sum(a.credito)
				  into _debito,
					   _credito
				  from chqchmae q, chqchcta c, chqctaux a
				 where q.no_requis       = c.no_requis
				   and c.no_requis       = a.no_requis
				   and c.renglon         = a.renglon
				   and q.pagado          = 1
				   and q.fecha_anulado   = _fecha
				   and c.cuenta          = _cuenta
				   and c.tipo            = _tipo;

				if _debito is null then 
					let _debito = 0.00;
				end if
				 
				if _credito is null then 
					let _credito = 0.00;
				end if

				if _debito2  <> _debito  then

					rollback work;
					return 1, _debito2, _debito, "Registros Debito NO Cuadran (2)";

				end if

				if _credito2 <> _credito then

					rollback work;
					return 1, _credito2, _credito, "Registros Credito NO Cuadran (2)";

				end if

				delete from cglresumen1
				 where res1_noregistro = a_noregistro;

				foreach
				 select a.cod_auxiliar,
				        a.debito,
						a.credito
				   into _cod_auxiliar,
				        _debito,
						_credito
				   from chqchmae q, chqchcta c, chqctaux a
				  where q.no_requis       = c.no_requis
				    and c.no_requis       = a.no_requis
				    and c.renglon         = a.renglon
				    and q.pagado          = 1
				    and q.fecha_anulado   = _fecha
				    and c.cuenta          = _cuenta
				    and c.tipo            = _tipo

					let _linea = _linea + 1;

					insert into cglresumen1	( res1_noregistro,res1_linea,res1_tipo_resumen,res1_comprobante,res1_cuenta,res1_auxiliar,res1_debito,res1_credito,res1_origen )
					values (a_noregistro, _linea, _tipo_resumen, _comprobante, _cuenta, _cod_auxiliar, _debito, _credito, _origen);

				end foreach

			end if
		{
		elif _cuenta[1,3] = "231" then

			select count(*)
			  into _cantidad
			  from cglresumen1
			 where res1_noregistro = a_noregistro;
			
			if _cantidad = 1 then

				update cglresumen1
				   set res1_debito     = _debito2,
				       res1_credito    = _credito2
				 where res1_noregistro = a_noregistro;

			else

				rollback work;
				return 1, "Hay mas de un resgistro";

			end if
		}
		else
			
			if _tipo = 1 then

				select sum(c.debito),
					   sum(c.credito)
				  into _debito,
					   _credito
				  from chqchmae q, chqchcta c
				 where q.no_requis       = c.no_requis
				   and q.pagado          = 1
				   and q.fecha_impresion = _fecha
				   and c.cuenta          = _cuenta
		--		   and q.no_cheque_ant   is not null
				   and c.tipo            = _tipo;

				if _debito is null then 
					let _debito = 0.00;
				end if
				 
				if _credito is null then 
					let _credito = 0.00;
				end if

				if _debito2  <> _debito  then

					rollback work;
					return 1, _debito2, _debito, "Registros NO Cuadran (3)";

				end if

				if _credito2 <> _credito then

					rollback work;
					return 1, _credito2, _credito, "Registros NO Cuadran (3)";

				end if

				delete from cglresumen1
				 where res1_noregistro = a_noregistro;

				foreach
				 select c.cod_auxiliar,
				        c.debito,
						c.credito
				   into _cod_auxiliar,
				        _debito,
						_credito
				   from chqchmae q, chqchcta c
				  where q.no_requis       = c.no_requis
				    and q.pagado          = 1
				    and q.fecha_impresion = _fecha
				    and c.cuenta          = _cuenta
				    and c.tipo            = _tipo
		--		    and q.no_cheque_ant   is not null

					let _linea = _linea + 1;

					insert into cglresumen1 ( res1_noregistro,res1_linea,res1_tipo_resumen,res1_comprobante,res1_cuenta,res1_auxiliar,res1_debito,res1_credito,res1_origen )
					values (a_noregistro, _linea, _tipo_resumen, _comprobante, _cuenta, _cod_auxiliar, _debito, _credito, _origen);

				end foreach

			else

				select sum(c.debito),
					   sum(c.credito)
				  into _debito,
					   _credito
				  from chqchmae q, chqchcta c
				 where q.no_requis       = c.no_requis
				   and q.pagado          = 1
				   and q.anulado         = 1
				   and q.fecha_anulado   = _fecha
		--		   and q.fecha_impresion = _fecha
				   and c.cuenta          = _cuenta
				   and c.tipo            = _tipo;

				if _debito is null then 
					let _debito = 0.00;
				end if
				 
				if _credito is null then 
					let _credito = 0.00;
				end if

				if _debito2  <> _debito  then

					rollback work;
					return 1, _debito2, _debito, "Registros NO Cuadran (4)";

				end if

				if _credito2 <> _credito then

					rollback work;
					return 1, _credito2, _credito, "Registros NO Cuadran (4)";

				end if

				delete from cglresumen1
				 where res1_noregistro = a_noregistro;

				foreach
				 select c.cod_auxiliar,
				        c.debito,
						c.credito
				   into _cod_auxiliar,
				        _debito,
						_credito
				   from chqchmae q, chqchcta c
				  where q.no_requis       = c.no_requis
				    and q.pagado          = 1
					and q.anulado         = 1
				    and q.fecha_anulado   = _fecha
		--    		and q.fecha_impresion = _fecha
				    and c.cuenta          = _cuenta
				    and c.tipo            = _tipo

					let _linea = _linea + 1;

					insert into cglresumen1	( res1_noregistro,res1_linea,res1_tipo_resumen,res1_comprobante,res1_cuenta,res1_auxiliar,res1_debito,res1_credito,res1_origen )
					values (a_noregistro, _linea, _tipo_resumen, _comprobante, _cuenta, _cod_auxiliar, _debito, _credito, _origen);

				end foreach

			end if

		end if

	elif _fuente = "PRO" then

		if _cuenta[1,3] = "231" then

			-- Solo debe Quedar Allied

			select sum(res1_debito),
			       sum(res1_credito)
			  into _debito,
				   _credito
			  from cglresumen1
			 where res1_noregistro = a_noregistro
			   and res1_auxiliar   = "RE034";

			if _debito is null then 
				let _debito = 0.00;
			end if
			 
			if _credito is null then 
				let _credito = 0.00;
			end if
			
			if _debito  = _debito2  and
			   _credito = _credito2 then
				
				delete from cglresumen1
				 where res1_noregistro = a_noregistro
				   and res1_auxiliar   <> "RE034";

			end if

			-- No debe estar Allied

			select sum(res1_debito),
			       sum(res1_credito)
			  into _debito,
				   _credito
			  from cglresumen1
			 where res1_noregistro = a_noregistro
			   and res1_auxiliar   <> "RE034";

			if _debito is null then 
				let _debito = 0.00;
			end if
			 
			if _credito is null then 
				let _credito = 0.00;
			end if
			
			if _debito  = _debito2  and
			   _credito = _credito2 then
				
				delete from cglresumen1
				 where res1_noregistro = a_noregistro
				   and res1_auxiliar   = "RE034";

			end if

		else

			select sum(x.debito),
			       sum(x.credito)
			  into _debito,
			       _credito
			  from endasien a, endasiau x
			 where a.no_poliza = x.no_poliza
			   and a.no_endoso = x.no_endoso
			   and a.cuenta    = x.cuenta
			   and a.sac_notrx = _notrx
			   and a.cuenta    = _cuenta
	--		   and x.cod_auxiliar <> "RE034"
			   and a.tipo_comp = _tipo;	 

			if _debito is null then 
				let _debito = 0.00;
			end if
			 
			if _credito is null then 
				let _credito = 0.00;
			end if

			let _credito = _credito * -1;

			if _debito2  <> _debito  then

				rollback work;
				return 1, _debito2, _debito, "Registros Debito NO Cuadran (5) " || _debito2 - _debito;

			end if

			if _credito2 <> _credito then

				rollback work;
				return 1, _credito2, _credito, "Registros Credito NO Cuadran (5) " || _credito2 - _credito;

			end if

			delete from cglresumen1
			 where res1_noregistro = a_noregistro;

			let _linea = 0;

		   foreach	
			select x.cod_auxiliar,
				   sum(x.debito),
			       sum(x.credito)
			  into _cod_auxiliar,
			       _debito,
			       _credito
			  from endasien a, endasiau x
			 where a.no_poliza = x.no_poliza
			   and a.no_endoso = x.no_endoso
			   and a.cuenta    = x.cuenta
			   and a.sac_notrx = _notrx
			   and a.cuenta    = _cuenta
			   and a.tipo_comp = _tipo
	--		   and x.cod_auxiliar <> "RE034"
			 group by x.cod_auxiliar 	 

				let _linea   = _linea + 1;
				let _credito = _credito * -1;

				insert into cglresumen1 ( res1_noregistro,res1_linea,res1_tipo_resumen,res1_comprobante,res1_cuenta,res1_auxiliar,res1_debito,res1_credito,res1_origen )
				values (a_noregistro, _linea, _tipo_resumen, _comprobante, _cuenta, _cod_auxiliar, _debito, _credito, _origen);

			end foreach

		end if

	elif _fuente = "REC" then

		select sum(x.debito),
		       sum(x.credito)
		  into _debito,
		       _credito
		  from recasien a, recasiau x
		 where a.no_tranrec = x.no_tranrec
		   and a.cuenta     = x.cuenta
		   and a.tipo_comp  = x.tipo_comp
		   and a.sac_notrx  = _notrx
		   and a.cuenta     = _cuenta
		   and a.tipo_comp  = _tipo;	 

		if _debito is null then 
			let _debito = 0.00;
		end if
		 
		if _credito is null then 
			let _credito = 0.00;
		end if

		let _credito = _credito * -1;

		if _debito2  <> _debito  then

			rollback work;
			return 1, _debito2, _debito, "Registros NO Cuadran (6)";

		end if

		if _credito2 <> _credito then

			rollback work;
			return 1, _credito2, _credito, "Registros NO Cuadran (6)";

		end if

		delete from cglresumen1
		 where res1_noregistro = a_noregistro;

		let _linea = 0;

		foreach
		 select sum(x.debito),
		        sum(x.credito),
				x.cod_auxiliar
		   into _debito,
		        _credito,
				_cod_auxiliar
		   from recasien a, recasiau x
		  where a.no_tranrec = x.no_tranrec
		    and a.cuenta     = x.cuenta
		    and a.tipo_comp  = x.tipo_comp
		    and a.sac_notrx  = _notrx
		    and a.cuenta     = _cuenta
		    and a.tipo_comp  = _tipo	 
		  group by x.cod_auxiliar 	 

			let _linea   = _linea + 1;
			let _credito = _credito * -1;

			insert into cglresumen1	( res1_noregistro,res1_linea,res1_tipo_resumen,res1_comprobante,res1_cuenta,res1_auxiliar,res1_debito,res1_credito,res1_origen )
			values (a_noregistro, _linea, _tipo_resumen, _comprobante, _cuenta, _cod_auxiliar, _debito, _credito, _origen);

		end foreach

	end if

end if

--rollback work;
commit work;

return 0, 0.00, 0.00, "Actualizacion Exitosa";

end procedure