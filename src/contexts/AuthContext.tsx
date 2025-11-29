import { createContext, useContext, useEffect, useState, ReactNode } from 'react';
import { authAdapter, User, UserProfile, AuthError } from '../lib/auth-adapter';

interface AuthContextType {
  user: User | null;
  userProfile: UserProfile | null;
  loading: boolean;
  isAdmin: boolean;
  signUp: (email: string, password: string, full_name?: string) => Promise<{ error: AuthError | null }>;
  signIn: (email: string, password: string) => Promise<{ error: AuthError | null }>;
  signOut: () => Promise<void>;
  refreshProfile: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [userProfile, setUserProfile] = useState<UserProfile | null>(null);
  const [loading, setLoading] = useState(true);

  const fetchUserProfile = async (userId: string) => {
    const profile = await authAdapter.fetchUserProfile(userId);
    if (profile) {
      setUserProfile(profile);
    }
  };

  useEffect(() => {
    const initAuth = async () => {
      const { user, token } = await authAdapter.getSession();
      setUser(user);
      if (user) {
        await fetchUserProfile(user.id);
      }
      setLoading(false);
    };

    initAuth();
  }, []);

  const signUp = async (email: string, password: string, full_name?: string) => {
    const response = await authAdapter.signUp(email, password, full_name);

    if (response.error) {
      return { error: response.error };
    }

    if (response.user) {
      setUser(response.user);
      await fetchUserProfile(response.user.id);
    }

    return { error: null };
  };

  const signIn = async (email: string, password: string) => {
    const response = await authAdapter.signIn(email, password);

    if (response.error) {
      return { error: response.error };
    }

    if (response.user) {
      setUser(response.user);
      await fetchUserProfile(response.user.id);
    }

    return { error: null };
  };

  const signOut = async () => {
    await authAdapter.signOut();
    setUser(null);
    setUserProfile(null);
  };

  const refreshProfile = async () => {
    if (user) {
      await fetchUserProfile(user.id);
    }
  };

  const isAdmin = userProfile?.role === 'admin';

  return (
    <AuthContext.Provider value={{
      user,
      userProfile,
      loading,
      isAdmin,
      signUp,
      signIn,
      signOut,
      refreshProfile
    }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
}
