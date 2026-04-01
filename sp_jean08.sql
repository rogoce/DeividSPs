
DROP procedure sp_jean08;
CREATE procedure sp_jean08(a_sac_notrx integer, a_cuenta char(25),a_noregistro integer, a_comprobante char(15))
RETURNING integer, dec(16,2), dec(16,2), integer;

DEFINE _cod_auxiliar    CHAR(10);
define _cuenta         char(25);
DEFINE _fecha         date;
define _cc       char(3);
define _db,_cr   dec(16,2);
define _renglon  integer;

let _renglon = 0;

foreach
	select a.centro_costo,a.fecha,a.cuenta,a.cod_auxiliar,sum(a.debito),sum(a.credito)
	  into _cc,_fecha,_cuenta,_cod_auxiliar,_db,_cr
	from chqctaux a, chqchcta b
	where a.no_requis = b.no_requis
	and a.renglon = b.renglon
	and a.cuenta = b.cuenta
	and b.sac_notrx = a_sac_notrx
	and a.cuenta = a_cuenta
--	and b.cuenta[1,3] = '570'
	group by a.centro_costo,a.fecha,a.cuenta,a.cod_auxiliar

    let _renglon = _renglon + 1;
	
	INSERT INTO cglresumen1
						( res1_noregistro,
						res1_linea		 ,
						res1_tipo_resumen,
						res1_comprobante ,
						res1_cuenta		 ,
						res1_auxiliar	 ,
						res1_debito		 ,
						res1_credito	 ,
						res1_origen		 ,
						res1_referencia
						)
				     VALUES (a_noregistro,
					     _renglon,
					     '01',
					     a_comprobante,
					     a_cuenta,
					     _cod_auxiliar,
					     _db,
					     _cr,
					     "CHE",
					     '');
	 
end foreach

select sum(res1_debito),
       sum(res1_credito)
  into _db,
       _cr
  from cglresumen1
 where res1_noregistro = a_noregistro;
 
 return a_noregistro,_db,_cr,_renglon;

END PROCEDURE;