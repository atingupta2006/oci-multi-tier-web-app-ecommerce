import { useEffect, useState } from 'react';
import { supabase } from '../lib/supabase';
import { AlertCircle, CheckCircle, Loader } from 'lucide-react';

export function ConnectionTest() {
  const [status, setStatus] = useState<'testing' | 'success' | 'error'>('testing');
  const [message, setMessage] = useState('Testing connection...');
  const [details, setDetails] = useState<any>(null);

  useEffect(() => {
    testConnection();
  }, []);

  const testConnection = async () => {
    try {
      console.log('🧪 Testing Supabase connection...');

      const startTime = Date.now();
      const { data, error, count } = await supabase
        .from('products')
        .select('*', { count: 'exact', head: false })
        .limit(1);

      const duration = Date.now() - startTime;

      if (error) {
        console.error('❌ Connection test failed:', error);
        setStatus('error');
        setMessage(`Connection failed: ${error.message}`);
        setDetails(error);
        return;
      }

      console.log('✅ Connection test successful');
      setStatus('success');
      setMessage(`Connected successfully! Found ${count} products in database.`);
      setDetails({
        duration: `${duration}ms`,
        sampleData: data,
        totalProducts: count,
      });
    } catch (err: any) {
      console.error('💥 Connection test error:', err);
      setStatus('error');
      setMessage(`Unexpected error: ${err.message}`);
      setDetails(err);
    }
  };

  return (
    <div className="fixed bottom-4 right-4 bg-white rounded-lg shadow-xl p-4 max-w-md border-2 border-gray-200 z-50">
      <div className="flex items-start gap-3">
        {status === 'testing' && (
          <Loader className="w-5 h-5 text-blue-600 animate-spin flex-shrink-0 mt-0.5" />
        )}
        {status === 'success' && (
          <CheckCircle className="w-5 h-5 text-green-600 flex-shrink-0 mt-0.5" />
        )}
        {status === 'error' && (
          <AlertCircle className="w-5 h-5 text-red-600 flex-shrink-0 mt-0.5" />
        )}

        <div className="flex-1 min-w-0">
          <h3 className="font-semibold text-gray-900 mb-1">Database Connection</h3>
          <p className="text-sm text-gray-600 mb-2">{message}</p>

          {details && (
            <div className="text-xs bg-gray-50 p-2 rounded mt-2 overflow-auto max-h-32">
              <pre className="whitespace-pre-wrap">{JSON.stringify(details, null, 2)}</pre>
            </div>
          )}

          <button
            onClick={testConnection}
            className="mt-2 text-xs text-blue-600 hover:text-blue-800 font-medium"
          >
            Test Again
          </button>
        </div>
      </div>
    </div>
  );
}
